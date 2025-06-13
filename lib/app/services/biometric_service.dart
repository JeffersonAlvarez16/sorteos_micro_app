import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import 'storage_service.dart';

class BiometricService extends GetxService {
  static BiometricService get to => Get.find();
  
  final LocalAuthentication _auth = LocalAuthentication();
  final StorageService _storage = StorageService.to;
  
  // Observable variables
  final RxBool _isBiometricAvailable = false.obs;
  final RxBool _isBiometricEnabled = false.obs;
  
  // Getters
  bool get isBiometricAvailable => _isBiometricAvailable.value;
  bool get isBiometricEnabled => _isBiometricEnabled.value;
  set isBiometricEnabled(bool value) {
    _isBiometricEnabled.value = value;
    _storage.biometricEnabled = value;
  }

  Future<BiometricService> init() async {
    // Verificar si el dispositivo soporta biometría
    await _checkBiometricSupport();
    
    // Cargar configuración guardada
    _isBiometricEnabled.value = _storage.biometricEnabled;
    
    return this;
  }
  
  // Verificar si el dispositivo soporta biometría
  Future<void> _checkBiometricSupport() async {
    try {
      // Verificar si hay hardware disponible
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      
      _isBiometricAvailable.value = canAuthenticate;
      
      if (canAuthenticate) {
        // Obtener tipos de biometría disponibles
        final availableBiometrics = await _auth.getAvailableBiometrics();
        
        print('Biometric types available: $availableBiometrics');
      }
    } on PlatformException catch (e) {
      print('Error checking biometrics availability: $e');
      _isBiometricAvailable.value = false;
    }
  }
  
  // Autenticar con biometría
  Future<bool> authenticate({
    String localizedReason = 'Autentícate para iniciar sesión',
    bool useErrorDialogs = true,
  }) async {
    if (!_isBiometricAvailable.value) {
      return false;
    }
    
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: useErrorDialogs,
        ),
      );
    } on PlatformException catch (e) {
      print('Error during biometric authentication: ${e.message}');
      
      // Manejar errores específicos
      if (e.code == auth_error.notEnrolled) {
        _showBiometricError('No hay datos biométricos registrados en este dispositivo.');
      } else if (e.code == auth_error.lockedOut || e.code == auth_error.permanentlyLockedOut) {
        _showBiometricError('Autenticación biométrica bloqueada. Por favor, utiliza tu PIN o contraseña.');
      } else {
        _showBiometricError('Error de autenticación biométrica: ${e.message}');
      }
      
      return false;
    } catch (e) {
      print('Unexpected error during biometric authentication: $e');
      _showBiometricError('Error inesperado durante la autenticación biométrica.');
      return false;
    }
  }
  
  // Mostrar diálogo de error
  void _showBiometricError(String message) {
    Get.snackbar(
      'Error de autenticación',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.fingerprint, color: Colors.white),
    );
  }
}
