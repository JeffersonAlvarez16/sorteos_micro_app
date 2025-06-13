import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // Services
  final AuthService _authService = AuthService.to;
  final StorageService _storageService = StorageService.to;
  final NotificationService _notificationService = NotificationService.to;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

  // Observable variables
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  final RxBool _rememberMe = false.obs;
  final RxBool _acceptTerms = false.obs;
  final RxString _currentView = 'login'.obs; // login, register, reset
  final RxBool _isPasswordValid = false.obs;
  final RxBool _isEmailValid = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;
  bool get rememberMe => _rememberMe.value;
  bool get acceptTerms => _acceptTerms.value;
  String get currentView => _currentView.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isEmailValid => _isEmailValid.value;
  bool get canLogin => isEmailValid && isPasswordValid && !isLoading;
  bool get canRegister => isEmailValid && isPasswordValid && 
                         fullNameController.text.isNotEmpty && acceptTerms && !isLoading;

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
  void _initializeController() {
    // Cargar datos guardados
    _rememberMe.value = _storageService.rememberMe;
    if (_rememberMe.value && _storageService.userEmail != null) {
      emailController.text = _storageService.userEmail!;
    }

    // Configurar listeners para validación en tiempo real
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
  }

  // Liberar controladores
  void _disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
  }

  // Cambiar vista actual
  void changeView(String view) {
    _currentView.value = view;
    _clearForm();
  }

  // Alternar visibilidad de contraseña
  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }

  // Alternar recordar sesión
  void toggleRememberMe() {
    _rememberMe.value = !_rememberMe.value;
  }

  // Alternar aceptar términos
  void toggleAcceptTerms() {
    _acceptTerms.value = !_acceptTerms.value;
  }

  // Validar email en tiempo real
  void _validateEmail() {
    _isEmailValid.value = GetUtils.isEmail(emailController.text);
  }

  // Validar contraseña en tiempo real
  void _validatePassword() {
    _isPasswordValid.value = passwordController.text.length >= 6;
  }

  // Login
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;

      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        rememberMe: _rememberMe.value,
      );

      if (result.success) {
        _showSuccess(result.message);
        
        // Suscribirse a notificaciones
        await _notificationService.subscribeToTopics();
        
        // Navegar al home
        Get.offAllNamed('/home');
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Registro
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    if (!_acceptTerms.value) {
      _showError('Debes aceptar los términos y condiciones');
      return;
    }

    try {
      _isLoading.value = true;

      final result = await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      );

      if (result.success) {
        _showSuccess(result.message);
        _currentView.value = 'login';
        _clearForm();
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Recuperar contraseña
  Future<void> resetPassword() async {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;

      final result = await _authService.resetPassword(emailController.text.trim());

      if (result.success) {
        _showSuccess(result.message);
        _currentView.value = 'login';
        _clearForm();
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Login con Google (placeholder para futura implementación)
  Future<void> loginWithGoogle() async {
    _showInfo('Próximamente disponible');
  }

  // Login con Apple (placeholder para futura implementación)
  Future<void> loginWithApple() async {
    _showInfo('Próximamente disponible');
  }

  // Limpiar formulario
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    fullNameController.clear();
    phoneController.clear();
    _acceptTerms.value = false;
    _isPasswordValid.value = false;
    _isEmailValid.value = false;
  }

  // Validadores de formulario
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

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

  // Obtener fortaleza de contraseña
  double getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    
    double strength = 0.0;
    
    // Longitud
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;
    
    // Mayúsculas
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    
    // Minúsculas
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    
    // Números
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.1;
    
    // Caracteres especiales
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;
    
    return strength.clamp(0.0, 1.0);
  }

  // Obtener color de fortaleza de contraseña
  Color getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.yellow;
    return Colors.green;
  }

  // Obtener texto de fortaleza de contraseña
  String getPasswordStrengthText(double strength) {
    if (strength < 0.3) return 'Débil';
    if (strength < 0.6) return 'Regular';
    if (strength < 0.8) return 'Buena';
    return 'Fuerte';
  }

  // Navegar a términos y condiciones
  void goToTermsAndConditions() {
    Get.toNamed('/terms');
  }

  // Navegar a política de privacidad
  void goToPrivacyPolicy() {
    Get.toNamed('/privacy');
  }

  // Verificar si hay sesión activa
  bool hasActiveSession() {
    return _authService.isAuthenticated;
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