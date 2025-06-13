import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/raffle_model.dart';
import '../data/models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../config/app_config.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  // Services
  final AuthService _authService = AuthService.to;
  final SupabaseService _supabaseService = SupabaseService.to;
  final NotificationService _notificationService = NotificationService.to;

  // Observable variables
  final RxList<RaffleModel> _activeRaffles = <RaffleModel>[].obs;
  final RxList<RaffleModel> _completedRaffles = <RaffleModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxInt _selectedTabIndex = 0.obs;
  final RxString _searchQuery = ''.obs;
  final RxBool _hasConnection = true.obs;
  final TextEditingController searchController = TextEditingController();

  // Real-time subscriptions
  RealtimeChannel? _rafflesSubscription;
  Timer? _refreshTimer;

  // Observable filter state
  final RxString _selectedFilter = 'all'.obs;

  // Getters
  List<RaffleModel> get activeRaffles => _activeRaffles;
  List<RaffleModel> get completedRaffles => _completedRaffles;
  String get selectedFilter => _selectedFilter.value;
  List<RaffleModel> get filteredRaffles {
    if (_selectedFilter.value == 'active') {
      return filteredActiveRaffles;
    } else if (_selectedFilter.value == 'completed') {
      return filteredCompletedRaffles;
    } else if (_selectedFilter.value == 'my_participations') {
      return filteredMyParticipations;
    } else {
      // 'all' or any other value
      return [...filteredActiveRaffles, ...filteredCompletedRaffles];
    }
  }
  
  List<RaffleModel> get filteredCompletedRaffles {
    if (_searchQuery.value.isEmpty) return _completedRaffles;
    return _completedRaffles.where((raffle) =>
      raffle.title.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
      raffle.description.toLowerCase().contains(_searchQuery.value.toLowerCase())
    ).toList();
  }

  List<RaffleModel> get filteredMyParticipations {
    final userId = _authService.currentUser?.id;
    if (userId == null) return [];

    final participatedRaffles = [..._activeRaffles, ..._completedRaffles]
      .where((raffle) => raffle.hasUserParticipated(userId))
      .toList();

    if (_searchQuery.value.isEmpty) return participatedRaffles;
    return participatedRaffles.where((raffle) =>
      raffle.title.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
      raffle.description.toLowerCase().contains(_searchQuery.value.toLowerCase())
    ).toList();
  }

  List<RaffleModel> get filteredActiveRaffles {
    if (_searchQuery.value.isEmpty) return _activeRaffles;
    return _activeRaffles.where((raffle) =>
      raffle.title.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
      raffle.description.toLowerCase().contains(_searchQuery.value.toLowerCase())
    ).toList();
  }
  
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  int get selectedTabIndex => _selectedTabIndex.value;
  String get searchQuery => _searchQuery.value;
  bool get hasConnection => _hasConnection.value;
  UserModel? get currentUser => _authService.currentUser;
  int get unreadNotifications => _notificationService.unreadCount;
  int get userParticipationsCount => filteredMyParticipations.length;
  int get activeRafflesCount => _activeRaffles.length;
  double get userBalance => _authService.currentUser?.balance ?? 0.0;
  bool get hasUnreadNotifications => unreadNotifications > 0;
  bool get isLoadingStats => _isLoading.value;
  bool get isLoadingMore => _isLoading.value && filteredRaffles.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onReady() {
    super.onReady();
    _setupRealTimeSubscriptions();
    _startPeriodicRefresh();
  }

  @override
  void onClose() {
    _rafflesSubscription?.unsubscribe();
    _refreshTimer?.cancel();
    super.onClose();
  }

  // Inicializar controlador
  Future<void> _initializeController() async {
    await _checkConnection();
    await loadActiveRaffles();
    await loadCompletedRaffles();
  }

  // Verificar conexión
  Future<void> _checkConnection() async {
    _hasConnection.value = await _supabaseService.checkConnection();
  }

  // Cargar sorteos activos
  Future<void> loadActiveRaffles() async {
    try {
      _isLoading.value = true;
      final raffles = await _supabaseService.getActiveRaffles();
      _activeRaffles.assignAll(raffles);
    } catch (e) {
      _showError('Error cargando sorteos: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Cargar sorteos completados
  Future<void> loadCompletedRaffles() async {
    try {
      final raffles = await _supabaseService.getCompletedRaffles(limit: 10);
      _completedRaffles.assignAll(raffles);
    } catch (e) {
      print('Error loading completed raffles: $e');
    }
  }

  // Refrescar datos
  Future<void> refreshData() async {
    try {
      _isRefreshing.value = true;
      await _checkConnection();
      
      if (_hasConnection.value) {
        await Future.wait([
          loadActiveRaffles(),
          loadCompletedRaffles(),
          _authService.refreshUser(),
        ]);
        
        _showSuccess('Datos actualizados');
      } else {
        _showError('Sin conexión a internet');
      }
    } catch (e) {
      _showError('Error actualizando datos: $e');
    } finally {
      _isRefreshing.value = false;
    }
  }

  // Configurar suscripciones en tiempo real
  void _setupRealTimeSubscriptions() {
    _rafflesSubscription = _supabaseService.subscribeToActiveRaffles((raffles) {
      _activeRaffles.assignAll(raffles);
    });
  }

  // Iniciar actualización periódica
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: AppConfig.refreshIntervalMinutes),
      (_) => refreshData(),
    );
  }

  // Cambiar tab seleccionado
  void changeTab(int index) {
    _selectedTabIndex.value = index;
    
    // Cargar datos específicos del tab si es necesario
    switch (index) {
      case 0: // Activos
        if (_activeRaffles.isEmpty) loadActiveRaffles();
        break;
      case 1: // Completados
        if (_completedRaffles.isEmpty) loadCompletedRaffles();
        break;
    }
  }

  // Actualizar búsqueda
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  // Limpiar búsqueda
  void clearSearch() {
    _searchQuery.value = '';
  }

  // Navegar a detalle de sorteo
  void goToRaffleDetail(String raffleId) {
    Get.toNamed('/raffle-detail', arguments: {'raffleId': raffleId});
  }

  // Navegar a perfil
  void goToProfile() {
    Get.toNamed('/profile');
  }

  // Navegar a depósitos
  void goToDeposits() {
    Get.toNamed('/deposits');
  }

  // Navegar a estadísticas
  void goToStatistics() {
    Get.toNamed('/statistics');
  }

  // Navegar a notificaciones
  void goToNotifications() {
    Get.toNamed('/notifications');
  }

  // Navegar a configuración
  void goToSettings() {
    Get.toNamed('/settings');
  }

  // Filter methods
  void setFilter(String filter) {
    _selectedFilter.value = filter;
  }

  void filterByStatus(String status) {
    if (status == 'active') {
      setFilter('active');
    } else if (status == 'completed') {
      setFilter('completed');
    } else if (status == 'my_participations') {
      setFilter('my_participations');
    } else {
      setFilter('all');
    }
  }

  void goToMyParticipations() {
    setFilter('my_participations');
  }
  
  // Comprar tickets rápido
  Future<void> quickPurchaseTickets(String raffleId, int ticketCount) async {
    try {
      if (_authService.currentUser == null) {
        _showError('Debes iniciar sesión');
        Get.toNamed('/login');
        return;
      }

      final raffle = _activeRaffles.firstWhereOrNull((r) => r.id == raffleId);
      if (raffle == null) {
        _showError('Sorteo no encontrado');
        return;
      }

      final totalAmount = raffle.ticketPrice * ticketCount;
      
      if (_authService.currentUser!.balance < totalAmount) {
        _showError('Saldo insuficiente');
        Get.toNamed('/deposits');
        return;
      }

      // Mostrar diálogo de confirmación
      final confirmed = await _showConfirmationDialog(
        title: 'Confirmar compra',
        message: 'Comprar $ticketCount tickets por €${totalAmount.toStringAsFixed(2)}?',
      );

      if (confirmed) {
        _isLoading.value = true;
        
        final result = await _supabaseService.purchaseTickets(
          raffleId: raffleId,
          ticketCount: ticketCount,
        );

        if (result != null) {
          _showSuccess('¡Tickets comprados exitosamente!');
          await _authService.refreshUser();
          await loadActiveRaffles();
        } else {
          _showError('Error comprando tickets');
        }
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Obtener color del estado del sorteo
  String getRaffleStatusColor(RaffleModel raffle) {
    switch (raffle.status) {
      case RaffleStatus.active:
        final timeLeft = raffle.endTime.difference(DateTime.now());
        if (timeLeft.inHours < 1) return 'red';
        if (timeLeft.inHours < 6) return 'orange';
        return 'green';
      case RaffleStatus.completed:
        return 'blue';
      case RaffleStatus.cancelled:
        return 'grey';
      default:
        return 'grey';
    }
  }

  // Verificar si el usuario puede participar
  bool canUserParticipate(RaffleModel raffle) {
    if (_authService.currentUser == null) return false;
    if (raffle.status != RaffleStatus.active) return false;
    if (raffle.endTime.isBefore(DateTime.now())) return false;
    if (raffle.soldTickets >= raffle.maxTickets) return false;
    
    return true;
  }
  
  // Obtener tiempo restante formateado
  String getTimeRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.isNegative) return 'Finalizado';
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  // Obtener probabilidad de ganar
  double getWinProbability(RaffleModel raffle) {
    if (raffle.maxTickets == 0) return 0.0;
    
    final userTickets = raffle.getUserTicketCount(_authService.currentUser?.id ?? '');
    return (userTickets / raffle.maxTickets) * 100;
  }

  // Obtener recomendación de tickets
  int getRecommendedTickets(RaffleModel raffle) {
    final balance = _authService.currentUser?.balance ?? 0.0;
    final maxAffordable = (balance / raffle.ticketPrice).floor();
    final remaining = raffle.maxTickets - raffle.soldTickets;
    
    // Recomendar entre 1-5 tickets, lo que sea menor
    return [maxAffordable, remaining, 5].reduce((a, b) => a < b ? a : b).clamp(1, 5);
  }

  // Get greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }
  
  // Handle menu action selection
  void handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        goToProfile();
        break;
      case 'deposits':
        goToDeposits();
        break;
      case 'history':
        goToMyParticipations();
        break;
      case 'settings':
        goToSettings();
        break;
    }
  }
  
  // Logout
  Future<void> logout() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Cerrar sesión',
      message: '¿Estás seguro que quieres cerrar sesión?',
    );

    if (confirmed) {
      await _authService.logout();
      Get.offAllNamed('/login');
    }
  }

  // Métodos de utilidad
  void _showSuccess(String message) {
    Get.snackbar(
      'Éxito',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 4),
    );
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    return await Get.dialog<bool>(
      AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }
} 