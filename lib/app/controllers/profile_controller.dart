import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  // Services
  final AuthService _authService = AuthService.to;
  final SupabaseService _supabaseService = SupabaseService.to;
  final StorageService _storageService = StorageService.to;
  final NotificationService _notificationService = NotificationService.to;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  // Observable variables
  final RxBool _isLoading = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isEditingProfile = false.obs;
  final RxBool _isChangingPassword = false.obs;
  final Rx<File?> _selectedAvatarImage = Rx<File?>(null);
  final RxMap<String, dynamic> _userStats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> _participationHistory = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _winningsHistory = <Map<String, dynamic>>[].obs;
  final RxBool _notificationsEnabled = true.obs;
  final RxString _selectedLanguage = 'es'.obs;
  final RxString _selectedTheme = 'light'.obs;
  final RxBool _pushNotificationsEnabled = true.obs;
  final RxBool _emailNotificationsEnabled = true.obs;
  final RxBool _biometricEnabled = false.obs;
  final RxBool _isSaving = false.obs;

  // Form controllers adicionales
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // Getters
  UserModel? get currentUser => _authService.currentUser;
  bool get isLoading => _isLoading.value;
  bool get isUpdating => _isUpdating.value;
  bool get isEditingProfile => _isEditingProfile.value;
  bool get isChangingPassword => _isChangingPassword.value;
  File? get selectedAvatarImage => _selectedAvatarImage.value;
  Map<String, dynamic> get userStats => _userStats;
  List<Map<String, dynamic>> get participationHistory => _participationHistory;
  List<Map<String, dynamic>> get winningsHistory => _winningsHistory;
  bool get notificationsEnabled => _notificationsEnabled.value;
  String get selectedLanguage => _selectedLanguage.value;
  String get selectedTheme => _selectedTheme.value;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled.value;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled.value;
  bool get biometricEnabled => _biometricEnabled.value;
  bool get isSaving => _isSaving.value;
  GlobalKey<FormState> get formKey => profileFormKey;

  // Estadísticas calculadas
  double get winRate => userStats['win_rate']?.toDouble() ?? 0.0;
  int get totalParticipations => userStats['total_raffles_participated'] ?? 0;
  int get totalWins => userStats['total_wins'] ?? 0;
  double get totalSpent => userStats['total_spent']?.toDouble() ?? 0.0;
  double get totalWinnings => userStats['total_winnings']?.toDouble() ?? 0.0;
  double get netResult => totalWinnings - totalSpent;
  int get currentStreak => userStats['current_streak'] ?? 0;
  int get maxStreak => userStats['max_streak'] ?? 0;

  // Getters adicionales para compatibilidad con la vista
  UserModel? get user => currentUser; // Alias para currentUser
  bool get isDarkMode => _selectedTheme.value == 'dark';
  
  // Métodos de navegación y acciones
  void Function() get changeAvatar => () => selectAvatarImage();
  void Function() get editProfile => () => startEditingProfile();
  
  void Function(String) get handleMenuAction => (String action) {
    switch (action) {
      case 'settings':
        goToSettings();
        break;
      case 'help':
        goToHelp();
        break;
      case 'terms':
        goToTerms();
        break;
      case 'privacy':
        goToPrivacy();
        break;
      case 'logout':
        logout();
        break;
    }
  };
  
  void Function() get viewMyRaffles => () {
    Get.toNamed('/my-raffles');
  };
  
  void Function() get viewDepositHistory => () {
    Get.toNamed('/deposits');
  };
  
  void Function() get managePaymentMethods => () {
    Get.toNamed('/payment-methods');
  };
  
  void Function() get configureNotifications => () {
    Get.toNamed('/notification-settings');
  };
  
  void Function() get toggleDarkMode => () {
    final newTheme = _selectedTheme.value == 'dark' ? 'light' : 'dark';
    changeTheme(newTheme);
  };

  // Additional methods
  void Function() get verifyAccount => () {
    Get.toNamed('/verify-account');
  };
  
  void Function() get exportData => () {
    _showInfo('Exportando datos...');
  };
  
  void Function() get saveProfile => () => updateProfile();
  
  void togglePushNotifications(bool value) {
    _pushNotificationsEnabled.value = value;
    // TODO: Implement save to preferences
    _showSuccess(value 
      ? 'Notificaciones push activadas' 
      : 'Notificaciones push desactivadas');
  }
  
  void toggleEmailNotifications(bool value) {
    _emailNotificationsEnabled.value = value;
    // TODO: Implement save to preferences
    _showSuccess(value 
      ? 'Notificaciones por correo electrónico activadas' 
      : 'Notificaciones por correo electrónico desactivadas');
  }
  
  void toggleBiometric(bool value) {
    _biometricEnabled.value = value;
    // TODO: Implement save to preferences and auth setup
    _showSuccess(value 
      ? 'Autenticación biométrica activada' 
      : 'Autenticación biométrica desactivada');
  }

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  // Inicializar controlador
  Future<void> _initializeController() async {
    _loadUserSettings();
    await _loadUserData();
  }

  // Cargar configuraciones del usuario
  void _loadUserSettings() {
    _notificationsEnabled.value = _storageService.notificationsEnabled;
    _selectedLanguage.value = _storageService.language;
    _selectedTheme.value = _storageService.themeMode;
    
    if (currentUser != null) {
      fullNameController.text = currentUser!.fullName ?? '';
      phoneController.text = currentUser!.phone ?? '';
      nameController.text = currentUser!.fullName ?? '';
      emailController.text = currentUser!.email;
    }
  }

  // Cargar datos del usuario
  Future<void> _loadUserData() async {
    try {
      _isLoading.value = true;
      
      await Future.wait([
        _loadUserStats(),
        _loadParticipationHistory(),
        _loadWinningsHistory(),
      ]);
    } catch (e) {
      _showError('Error cargando datos: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Cargar estadísticas del usuario
  Future<void> _loadUserStats() async {
    try {
      final stats = await _supabaseService.getUserStats();
      _userStats.assignAll(stats);
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  // Cargar historial de participaciones
  Future<void> _loadParticipationHistory() async {
    try {
      final history = await _supabaseService.getUserParticipationHistory(limit: 20);
      _participationHistory.assignAll(history);
    } catch (e) {
      print('Error loading participation history: $e');
    }
  }

  // Cargar historial de ganancias
  Future<void> _loadWinningsHistory() async {
    try {
      final winnings = await _supabaseService.getUserWinnings(limit: 10);
      _winningsHistory.assignAll(winnings);
    } catch (e) {
      print('Error loading winnings history: $e');
    }
  }

  // Refrescar datos
  Future<void> refreshData() async {
    await _authService.refreshUser();
    await _loadUserData();
  }

  // Iniciar edición de perfil
  void startEditingProfile() {
    _isEditingProfile.value = true;
    if (currentUser != null) {
      fullNameController.text = currentUser!.fullName ?? '';
      phoneController.text = currentUser!.phone ?? '';
    }
  }

  // Cancelar edición de perfil
  void cancelEditingProfile() {
    _isEditingProfile.value = false;
    _selectedAvatarImage.value = null;
    if (currentUser != null) {
      fullNameController.text = currentUser!.fullName ?? '';
      phoneController.text = currentUser!.phone ?? '';
    }
  }

  // Seleccionar imagen de avatar
  Future<void> selectAvatarImage({bool fromCamera = false}) async {
    try {
      // Solicitar permisos
      final permission = fromCamera ? Permission.camera : Permission.photos;
      final status = await permission.request();
      
      if (!status.isGranted) {
        _showError('Permisos necesarios no concedidos');
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedAvatarImage.value = File(image.path);
      }
    } catch (e) {
      _showError('Error seleccionando imagen: $e');
    }
  }

  // Remover imagen de avatar
  void removeAvatarImage() {
    _selectedAvatarImage.value = null;
  }

  // Actualizar perfil
  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    try {
      _isUpdating.value = true;
      _isSaving.value = true;

      String? avatarUrl;
      
      // Subir nueva imagen de avatar si se seleccionó
      if (_selectedAvatarImage.value != null) {
        final fileName = 'avatar_${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        avatarUrl = await _supabaseService.client.storage
            .from('avatars')
            .upload(fileName, _selectedAvatarImage.value!);
        
        if (avatarUrl != null) {
          avatarUrl = _supabaseService.client.storage
              .from('avatars')
              .getPublicUrl(fileName);
        }
      }

      // Actualizar perfil
      final result = await _authService.updateProfile(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        avatar: avatarUrl,
      );

      if (result.success) {
        _showSuccess(result.message);
        _isEditingProfile.value = false;
        _selectedAvatarImage.value = null;
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Error actualizando perfil: $e');
    } finally {
      _isUpdating.value = false;
      _isSaving.value = false;
    }
  }

  // Mostrar diálogo de cambio de contraseña
  void showChangePasswordDialog() {
    _isChangingPassword.value = true;
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  // Cancelar cambio de contraseña
  void cancelChangePassword() {
    _isChangingPassword.value = false;
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  // Cambiar contraseña
  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    try {
      _isUpdating.value = true;

      final result = await _authService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (result.success) {
        _showSuccess(result.message);
        cancelChangePassword();
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Error cambiando contraseña: $e');
    } finally {
      _isUpdating.value = false;
    }
  }

  // Alternar notificaciones
  Future<void> toggleNotifications() async {
    try {
      _notificationsEnabled.value = !_notificationsEnabled.value;
      _storageService.notificationsEnabled = _notificationsEnabled.value;
      
      if (_notificationsEnabled.value) {
        await _notificationService.subscribeToTopics();
        _showSuccess('Notificaciones activadas');
      } else {
        await _notificationService.unsubscribeFromTopics();
        _showSuccess('Notificaciones desactivadas');
      }
    } catch (e) {
      _showError('Error configurando notificaciones: $e');
    }
  }

  // Cambiar idioma
  void changeLanguage(String language) {
    _selectedLanguage.value = language;
    _storageService.language = language;
    Get.updateLocale(Locale(language));
    _showSuccess('Idioma cambiado');
  }

  // Cambiar tema
  void changeTheme(String theme) {
    _selectedTheme.value = theme;
    _storageService.themeMode = theme;
    Get.changeThemeMode(
      theme == 'dark' ? ThemeMode.dark : 
      theme == 'light' ? ThemeMode.light : ThemeMode.system
    );
    _showSuccess('Tema cambiado');
  }

  // Navegar a historial completo
  void goToFullParticipationHistory() {
    Get.toNamed('/participation-history');
  }

  void goToFullWinningsHistory() {
    Get.toNamed('/winnings-history');
  }

  // Navegar a configuraciones
  void goToSettings() {
    Get.toNamed('/settings');
  }

  // Navegar a ayuda
  void goToHelp() {
    Get.toNamed('/help');
  }

  // Navegar a términos y condiciones
  void goToTerms() {
    Get.toNamed('/terms');
  }

  // Navegar a política de privacidad
  void goToPrivacy() {
    Get.toNamed('/privacy');
  }

  // Cerrar sesión
  Future<void> logout() async {
    final confirmed = await _showLogoutConfirmation();
    if (confirmed) {
      await _authService.logout();
      Get.offAllNamed('/login');
    }
  }

  // Eliminar cuenta
  Future<void> deleteAccount() async {
    final confirmed = await _showDeleteAccountConfirmation();
    if (confirmed) {
      // Implementar eliminación de cuenta
      _showInfo('Función próximamente disponible');
    }
  }

  // Liberar controladores
  void _disposeControllers() {
    fullNameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  // Validadores
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre completo es requerido';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isPhoneNumber(value)) {
        return 'Ingresa un número de teléfono válido';
      }
    }
    return null;
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña actual es requerida';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La nueva contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu nueva contraseña';
    }
    if (value != newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Obtener color del resultado neto
  Color getNetResultColor() {
    if (netResult > 0) return Colors.green;
    if (netResult < 0) return Colors.red;
    return Colors.grey;
  }

  // Obtener texto del resultado neto
  String getNetResultText() {
    if (netResult > 0) return '+€${netResult.toStringAsFixed(2)}';
    if (netResult < 0) return '-€${netResult.abs().toStringAsFixed(2)}';
    return '€0.00';
  }

  // Formatear fecha
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Mostrar confirmación de logout
  Future<bool> _showLogoutConfirmation() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Mostrar confirmación de eliminación de cuenta
  Future<bool> _showDeleteAccountConfirmation() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro que quieres eliminar tu cuenta? Esta acción no se puede deshacer.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Eliminar'),
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

  // Validation methods
  String? validateName(String? value) => validateFullName(value);
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }
} 