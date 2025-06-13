import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/raffle_model.dart';
import '../data/models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/payment_service.dart';
import '../config/app_config.dart';

class RaffleController extends GetxController {
  static RaffleController get to => Get.find();

  // Services
  final AuthService _authService = AuthService.to;
  final SupabaseService _supabaseService = SupabaseService.to;
  final PaymentService _paymentService = PaymentService.to;

  // Observable variables
  final Rx<RaffleModel?> _currentRaffle = Rx<RaffleModel?>(null);
  final RxList<String> _userTickets = <String>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isPurchasing = false.obs;
  final RxInt _selectedTicketCount = 1.obs;
  final RxBool _showTicketSelector = false.obs;
  final RxMap<String, dynamic> _raffleStats = <String, dynamic>{}.obs;
  final RxBool _isSubscribed = false.obs;
  final RxString _timeRemaining = ''.obs;

  // Real-time subscriptions
  RealtimeChannel? _raffleSubscription;
  RealtimeChannel? _ticketsSubscription;
  Timer? _countdownTimer;

  // Getters
  RaffleModel? get currentRaffle => _currentRaffle.value;
  List<String> get userTickets => _userTickets;
  bool get isLoading => _isLoading.value;
  bool get isPurchasing => _isPurchasing.value;
  int get selectedTicketCount => _selectedTicketCount.value;
  bool get showTicketSelector => _showTicketSelector.value;
  Map<String, dynamic> get raffleStats => _raffleStats;
  bool get isSubscribed => _isSubscribed.value;
  String get timeRemaining => _timeRemaining.value;
  
  UserModel? get currentUser => _authService.currentUser;
  bool get canPurchaseTickets => 
      currentRaffle != null &&
      currentRaffle!.status == 'active' &&
      currentRaffle!.endDate.isAfter(DateTime.now()) &&
      currentRaffle!.soldTickets < currentRaffle!.maxTickets &&
      currentUser != null &&
      !isPurchasing;

  double get totalCost => 
      currentRaffle != null ? currentRaffle!.ticketPrice * selectedTicketCount : 0.0;
  
  bool get hasEnoughBalance => 
      currentUser != null && currentUser!.balance >= totalCost;

  int get maxAffordableTickets {
    if (currentRaffle == null || currentUser == null) return 0;
    return (currentUser!.balance / currentRaffle!.ticketPrice).floor();
  }

  int get maxAvailableTickets {
    if (currentRaffle == null) return 0;
    return currentRaffle!.maxTickets - currentRaffle!.soldTickets;
  }

  int get maxPurchasableTickets {
    return [maxAffordableTickets, maxAvailableTickets, AppConfig.maxTicketsPerPurchase]
        .reduce((a, b) => a < b ? a : b);
  }

  double get winProbability {
    if (currentRaffle == null || currentRaffle!.maxTickets == 0) return 0.0;
    return (selectedTicketCount / currentRaffle!.maxTickets) * 100;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _cleanupSubscriptions();
    super.onClose();
  }

  // Inicializar controlador
  void _initializeController() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final raffleId = arguments?['raffleId'] as String?;
    
    if (raffleId != null) {
      loadRaffleDetails(raffleId);
    }
  }

  // Cargar detalles del sorteo
  Future<void> loadRaffleDetails(String raffleId) async {
    try {
      _isLoading.value = true;
      
      // Cargar sorteo
      final raffle = await _supabaseService.getRaffleById(raffleId);
      if (raffle != null) {
        _currentRaffle.value = raffle;
        
        // Cargar tickets del usuario
        await _loadUserTickets(raffleId);
        
        // Cargar estadísticas
        await _loadRaffleStats(raffleId);
        
        // Configurar suscripciones en tiempo real
        _setupRealTimeSubscriptions(raffleId);
        
        // Iniciar countdown
        _startCountdown();
      } else {
        _showError('Sorteo no encontrado');
        Get.back();
      }
    } catch (e) {
      _showError('Error cargando sorteo: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Cargar tickets del usuario
  Future<void> _loadUserTickets(String raffleId) async {
    try {
      final tickets = await _supabaseService.getUserTicketsForRaffle(raffleId);
      _userTickets.assignAll(tickets);
    } catch (e) {
      print('Error loading user tickets: $e');
    }
  }

  // Cargar estadísticas del sorteo
  Future<void> _loadRaffleStats(String raffleId) async {
    try {
      final stats = await _supabaseService.getRaffleStats(raffleId);
      _raffleStats.assignAll(stats);
    } catch (e) {
      print('Error loading raffle stats: $e');
    }
  }

  // Configurar suscripciones en tiempo real
  void _setupRealTimeSubscriptions(String raffleId) {
    // Suscribirse a cambios en el sorteo
    _raffleSubscription = _supabaseService.subscribeToRaffle(raffleId, (raffle) {
      if (raffle != null) {
        _currentRaffle.value = raffle;
      }
    });

    // Suscribirse a cambios en tickets
    _ticketsSubscription = _supabaseService.subscribeToRaffleTickets(raffleId, () {
      _loadUserTickets(raffleId);
      _loadRaffleStats(raffleId);
    });

    _isSubscribed.value = true;
  }

  // Iniciar countdown
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
    _updateTimeRemaining();
  }

  // Actualizar tiempo restante
  void _updateTimeRemaining() {
    if (currentRaffle == null) return;
    
    final now = DateTime.now();
    final endDate = currentRaffle!.endDate;
    final difference = endDate.difference(now);
    
    if (difference.isNegative) {
      _timeRemaining.value = 'Finalizado';
      _countdownTimer?.cancel();
    } else {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;
      
      if (days > 0) {
        _timeRemaining.value = '${days}d ${hours}h ${minutes}m ${seconds}s';
      } else if (hours > 0) {
        _timeRemaining.value = '${hours}h ${minutes}m ${seconds}s';
      } else if (minutes > 0) {
        _timeRemaining.value = '${minutes}m ${seconds}s';
      } else {
        _timeRemaining.value = '${seconds}s';
      }
    }
  }

  // Mostrar selector de tickets
  void showTicketSelector() {
    if (!canPurchaseTickets) {
      if (currentUser == null) {
        _showError('Debes iniciar sesión');
        Get.toNamed('/login');
        return;
      }
      if (!hasEnoughBalance) {
        _showError('Saldo insuficiente');
        Get.toNamed('/deposits');
        return;
      }
      return;
    }
    
    _selectedTicketCount.value = 1;
    _showTicketSelector.value = true;
  }

  // Ocultar selector de tickets
  void hideTicketSelector() {
    _showTicketSelector.value = false;
  }

  // Cambiar cantidad de tickets seleccionados
  void changeTicketCount(int count) {
    if (count < 1) count = 1;
    if (count > maxPurchasableTickets) count = maxPurchasableTickets;
    _selectedTicketCount.value = count;
  }

  // Incrementar tickets
  void incrementTickets() {
    if (selectedTicketCount < maxPurchasableTickets) {
      _selectedTicketCount.value++;
    }
  }

  // Decrementar tickets
  void decrementTickets() {
    if (selectedTicketCount > 1) {
      _selectedTicketCount.value--;
    }
  }

  // Comprar tickets
  Future<void> purchaseTickets() async {
    if (!canPurchaseTickets || currentRaffle == null) return;

    try {
      _isPurchasing.value = true;

      // Verificar balance nuevamente
      if (!hasEnoughBalance) {
        _showError('Saldo insuficiente');
        Get.toNamed('/deposits');
        return;
      }

      // Mostrar confirmación
      final confirmed = await _showPurchaseConfirmation();
      if (!confirmed) return;

      // Realizar compra
      final result = await _supabaseService.purchaseTickets(
        raffleId: currentRaffle!.id,
        ticketCount: selectedTicketCount,
      );

      if (result != null) {
        _showSuccess('¡Tickets comprados exitosamente!');
        
        // Actualizar datos
        await Future.wait([
          _authService.refreshUser(),
          loadRaffleDetails(currentRaffle!.id),
        ]);
        
        hideTicketSelector();
      } else {
        _showError('Error comprando tickets');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      _isPurchasing.value = false;
    }
  }

  // Refrescar datos
  Future<void> refreshData() async {
    if (currentRaffle != null) {
      await loadRaffleDetails(currentRaffle!.id);
    }
  }

  // Compartir sorteo
  void shareRaffle() {
    if (currentRaffle == null) return;
    
    final shareText = '''
🎉 ¡Participa en el sorteo "${currentRaffle!.title}"!

💰 Premio: €${currentRaffle!.prizeAmount}
🎫 Precio por ticket: €${currentRaffle!.ticketPrice}
⏰ Finaliza: ${_formatDate(currentRaffle!.endDate)}

¡Descarga SorteosMicro y participa!
    ''';
    
    // Aquí implementarías el share nativo
    _showInfo('Función de compartir próximamente');
  }

  // Ver historial de participaciones
  void viewParticipationHistory() {
    Get.toNamed('/participation-history');
  }

  // Ver reglas del sorteo
  void viewRaffleRules() {
    Get.toNamed('/raffle-rules', arguments: {'raffle': currentRaffle});
  }

  // Obtener color del progreso
  Color getProgressColor() {
    if (currentRaffle == null) return Colors.grey;
    
    final progress = currentRaffle!.soldTickets / currentRaffle!.maxTickets;
    if (progress < 0.3) return Colors.green;
    if (progress < 0.7) return Colors.orange;
    return Colors.red;
  }

  // Obtener texto del estado
  String getStatusText() {
    if (currentRaffle == null) return '';
    
    switch (currentRaffle!.status) {
      case 'active':
        if (currentRaffle!.endDate.isBefore(DateTime.now())) {
          return 'Finalizado';
        }
        return 'Activo';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return currentRaffle!.status;
    }
  }

  // Obtener recomendación de tickets
  String getTicketRecommendation() {
    if (currentRaffle == null) return '';
    
    final recommended = (currentRaffle!.maxTickets * 0.05).ceil(); // 5% del total
    final affordable = maxAffordableTickets;
    final suggestion = [recommended, affordable, 5].reduce((a, b) => a < b ? a : b);
    
    return 'Recomendado: $suggestion tickets (${(suggestion / currentRaffle!.maxTickets * 100).toStringAsFixed(1)}% probabilidad)';
  }

  // Limpiar suscripciones
  void _cleanupSubscriptions() {
    _raffleSubscription?.unsubscribe();
    _ticketsSubscription?.unsubscribe();
    _countdownTimer?.cancel();
    _isSubscribed.value = false;
  }

  // Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Mostrar confirmación de compra
  Future<bool> _showPurchaseConfirmation() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sorteo: ${currentRaffle!.title}'),
            const SizedBox(height: 8),
            Text('Tickets: $selectedTicketCount'),
            Text('Precio total: €${totalCost.toStringAsFixed(2)}'),
            Text('Probabilidad: ${winProbability.toStringAsFixed(2)}%'),
            const SizedBox(height: 16),
            const Text('¿Confirmas la compra?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Comprar'),
          ),
        ],
      ),
    ) ?? false;
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
      icon: const Icon(Icons.check_circle, color: Colors.white),
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
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void _showInfo(String message) {
    Get.snackbar(
      'Información',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.secondary,
      colorText: Get.theme.colorScheme.onSecondary,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }
} 