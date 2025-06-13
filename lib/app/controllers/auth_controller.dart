import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/biometric_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // Services
  final AuthService _authService = AuthService.to;
  final StorageService _storageService = StorageService.to;
  final NotificationService _notificationService = NotificationService.to;
  final BiometricService _biometricService = BiometricService.to;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> recoveryFormKey = GlobalKey<FormState>();

  // Observable variables
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  final RxBool _rememberMe = false.obs;
  final RxBool _acceptTerms = false.obs;
  final RxBool _isPasswordValid = false.obs;
  final RxBool _isEmailValid = false.obs;
  final RxBool _isLoginMode = true.obs;
  final RxBool _isRecoveryMode = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;
  RxBool get rememberMe => _rememberMe;
  RxBool get acceptTerms => _acceptTerms;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isEmailValid => _isEmailValid.value;
  RxBool get isLoginMode => _isLoginMode;
  RxBool get isRecoveryMode => _isRecoveryMode;
  bool get canLogin => isEmailValid && isPasswordValid && !isLoading;
  bool get canRegister => isEmailValid && isPasswordValid && 
                         fullNameController.text.isNotEmpty && acceptTerms.value && !isLoading;
  bool get canSendReset => isEmailValid && !isLoading;

  @override
  void onInit() {
    super.onInit();
    _checkLoggedInUser();
    _tryBiometricLogin();
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

  // Verificar si hay un usuario logueado
  Future<void> _checkLoggedInUser() async {
    _isLoading.value = true;
    await _authService.checkExistingSession();
    _isLoading.value = false;
  }

  // Intentar autenticación biométrica
  Future<void> _tryBiometricLogin() async {
    // Solo intentar si no hay una sesión activa y si la biometría está disponible y habilitada
    if (_authService.currentUser == null && 
        _biometricService.isBiometricAvailable && 
        _biometricService.isBiometricEnabled) {
      
      try {
        final bool authenticated = await _biometricService.authenticate(
          localizedReason: 'Autentícate para ingresar a tu cuenta',
        );
        
        if (authenticated) {
          // Si la autenticación biométrica es exitosa, intentar iniciar sesión con credenciales guardadas
          final String? email = _storageService.userEmail;
          final String? password = _storageService.userPassword;
          
          if (email != null && password != null) {
            _isLoading.value = true;
            
            final result = await _authService.login(
              email: email,
              password: password,
              rememberMe: true, // Si usa biometría, queremos recordar la sesión
            );
            
            if (result.success) {
              _showSuccess('Sesión iniciada correctamente');
              Get.offAllNamed('/home');
            } else {
              _showError('No se pudo iniciar sesión automáticamente');
            }
            
            _isLoading.value = false;
          }
        }
      } catch (e) {
        print('Error en autenticación biométrica: $e');
      }
    }
  }

  // Alternar modo de autenticación
  void toggleAuthMode() {
    _isLoginMode.value = !_isLoginMode.value;
    _isRecoveryMode.value = false;
    _clearForm();
  }

  // Ir a recuperación de contraseña
  void goToRecovery() {
    _isRecoveryMode.value = true;
    _isLoginMode.value = false;
    _clearForm();
  }

  // Volver al login
  void backToLogin() {
    _isLoginMode.value = true;
    _isRecoveryMode.value = false;
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
  void toggleRememberMe(bool? value) {
    if (value != null) {
      _rememberMe.value = value;
    }
  }

  // Alternar aceptar términos
  void toggleAcceptTerms(bool? value) {
    if (value != null) {
      _acceptTerms.value = value;
    }
  }

  // Callbacks para cambios en los campos
  void onEmailChanged(String value) {
    _validateEmail();
  }

  void onPasswordChanged(String value) {
    _validatePassword();
  }

  void onFullNameChanged(String value) {
    // Trigger validation if needed
  }

  void onPhoneChanged(String value) {
    // Trigger validation if needed
  }

  void onConfirmPasswordChanged(String value) {
    // Trigger validation if needed
  }

  // Validar email en tiempo real
  void _validateEmail() {
    _isEmailValid.value = GetUtils.isEmail(emailController.text);
  }

  // Validar contraseña en tiempo real
  void _validatePassword() {
    _isPasswordValid.value = passwordController.text.length >= 6;
  }

  // Obtener subtítulo según el modo actual
  String _getSubtitle() {
    if (_isRecoveryMode.value) {
      return 'Recupera tu contraseña';
    } else if (_isLoginMode.value) {
      return 'Bienvenido de vuelta';
    } else {
      return 'Crea tu cuenta';
    }
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
        //await _notificationService.subscribeToTopics();
        
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
        toggleAuthMode(); // Volver al login
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Enviar correo de recuperación de contraseña
  Future<void> sendPasswordReset() async {
    if (!recoveryFormKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;

      final result = await _authService.resetPassword(emailController.text.trim());

      if (result.success) {
        _showSuccess(result.message);
        backToLogin();
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Login con Google
  Future<void> signInWithGoogle() async {
    _showInfo('Login con Google próximamente disponible');
  }

  // Login con Apple
  Future<void> signInWithApple() async {
    _showInfo('Login con Apple próximamente disponible');
  }

  // Abrir soporte
  void openSupport() {
    Get.toNamed('/support');
  }

  // Abrir política de privacidad
  void openPrivacyPolicy() {
    Get.toNamed('/privacy');
  }

  // Abrir términos y condiciones
  void openTerms() {
    Get.toNamed('/terms');
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