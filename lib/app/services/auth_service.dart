import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_model.dart';
import '../config/app_config.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storage = StorageService.to;

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isAuthenticated = false.obs;

  // Getters
  UserModel? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  User? get supabaseUser => _supabase.auth.currentUser;

  Future<AuthService> init() async {
    // Escuchar cambios de autenticación
    _supabase.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data.event, data.session);
    });

    // Verificar sesión existente
    await _checkExistingSession();

    return this;
  }

  // Verificar sesión existente
  Future<void> _checkExistingSession() async {
    try {
      _isLoading.value = true;

      final session = _supabase.auth.currentSession;
      
      // Si hay sesión en Supabase
      if (session != null) {
        // Si está marcado recordar sesión o está marcado como logged in
        if (_storage.rememberMe || _storage.isLoggedIn) {
          await _loadCurrentUser();
          _isAuthenticated.value = true;
        } else {
          // Si no debemos recordar la sesión, cerrarla
          await _supabase.auth.signOut();
          _storage.clearUserSession();
          _isAuthenticated.value = false;
        }
      } else {
        // No hay sesión activa
        _storage.clearUserSession();
        _isAuthenticated.value = false;
      }
    } catch (e) {
      print('Error checking existing session: $e');
      _storage.clearUserSession();
      _isAuthenticated.value = false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Manejar cambios de estado de autenticación
  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    switch (event) {
      case AuthChangeEvent.signedIn:
        if (session != null) {
          _loadCurrentUser();
          _isAuthenticated.value = true;
        }
        break;
      case AuthChangeEvent.signedOut:
        _currentUser.value = null;
        _isAuthenticated.value = false;
        _storage.clearUserSession();
        break;
      case AuthChangeEvent.userUpdated:
        if (session != null) {
          _loadCurrentUser();
        }
        break;
      default:
        break;
    }
  }

  // Cargar usuario actual
  Future<void> _loadCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('users')
            .select('*, user_stats(*)')
            .eq('id', user.id)
            .single();

        _currentUser.value = UserModel.fromJson(response);

        // Guardar en storage
        _storage.saveUserSession(
          userId: user.id,
          email: user.email ?? '',
          token: _supabase.auth.currentSession?.accessToken ?? '',
        );

        // Actualizar FCM token
        await _updateFcmToken();
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  // Actualizar FCM token
  Future<void> _updateFcmToken() async {
    try {
      final fcmToken = _storage.fcmToken;
      if (fcmToken != null && currentUser != null) {
        await _supabase
            .from('users')
            .update({'fcm_token': fcmToken}).eq('id', currentUser!.id);
      } else {
        // Skip FCM token update if not available
        print(
            'Skipping FCM token update: token=${fcmToken != null}, user=${currentUser != null}');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
      // Continue even if FCM token update fails
    }
  }

  // Registro de usuario
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      _isLoading.value = true;

      // Validaciones
      if (!GetUtils.isEmail(email)) {
        return AuthResult.error('Email no válido');
      }
      if (password.length < 6) {
        return AuthResult.error(
            'La contraseña debe tener al menos 6 caracteres');
      }
      if (fullName.trim().isEmpty) {
        return AuthResult.error('El nombre completo es requerido');
      }

      // Registro en Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'email_verified': true,
        },
      );

      if (response.user != null) {
        // Crear perfil de usuario
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          phone: phone,
        );

        return AuthResult.success('Registro exitoso. Verifica tu email.');
      } else {
        return AuthResult.error('Error en el registro');
      }
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Crear perfil de usuario
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
  }) async {
    try {
      // Crear usuario en la tabla users
      await _supabase.from('users').upsert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'balance': 0.0,
        'is_active': true,
        'email_verified': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Crear estadísticas iniciales
      final existingStats = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existingStats == null) {
        await _supabase.from('user_stats').insert({
          'user_id': userId,
          'total_tickets_purchased': 0,
          'total_raffles_participated': 0,
          'total_wins': 0,
          'total_winnings': 0.0,
          'total_spent': 0.0,
          'current_streak': 0,
          'max_streak': 0,
          'win_rate': 0.0,
        });
      }
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }

  // Login de usuario
  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _isLoading.value = true;

      // Validaciones
      if (!GetUtils.isEmail(email)) {
        return AuthResult.error('Email no válido');
      }
      if (password.isEmpty) {
        return AuthResult.error('La contraseña es requerida');
      }

      // Login en Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Cargar datos del usuario
        await _loadCurrentUser();
        
        // Guardar preferencia de recordar
        _storage.rememberMe = rememberMe;

        return AuthResult.success('Login exitoso');
      } else {
        return AuthResult.error('Credenciales inválidas');
      }
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Limpiar FCM token
      if (currentUser != null) {
        await _supabase
            .from('users')
            .update({'fcm_token': null}).eq('id', currentUser!.id);
      }

      // Logout de Supabase
      await _supabase.auth.signOut();

      // Limpiar storage
      _storage.clearUserSession();

      // Limpiar notificaciones
      await NotificationService.to.clearAllNotifications();
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Recuperar contraseña
  Future<AuthResult> resetPassword(String email) async {
    try {
      _isLoading.value = true;

      if (!GetUtils.isEmail(email)) {
        return AuthResult.error('Email no válido');
      }

      await _supabase.auth.resetPasswordForEmail(email);
      return AuthResult.success('Instrucciones enviadas a tu email');
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Actualizar perfil
  Future<AuthResult> updateProfile({
    String? fullName,
    String? phone,
    String? avatar,
  }) async {
    try {
      _isLoading.value = true;

      if (currentUser == null) {
        return AuthResult.error('Usuario no autenticado');
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatar != null) updates['avatar'] = avatar;

      if (updates.isNotEmpty) {
        await _supabase.from('users').update(updates).eq('id', currentUser!.id);

        // Recargar usuario
        await _loadCurrentUser();
      }

      return AuthResult.success('Perfil actualizado');
    } catch (e) {
      return AuthResult.error('Error actualizando perfil: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Cambiar contraseña
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;

      if (newPassword.length < 6) {
        return AuthResult.error(
            'La nueva contraseña debe tener al menos 6 caracteres');
      }

      // Verificar contraseña actual
      final email = currentUser?.email;
      if (email == null) {
        return AuthResult.error('Usuario no autenticado');
      }

      // Re-autenticar
      await _supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      // Cambiar contraseña
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return AuthResult.success('Contraseña cambiada exitosamente');
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e.message));
    } catch (e) {
      return AuthResult.error('Error cambiando contraseña: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Recargar usuario
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  // Obtener mensajes de error localizados
  String _getAuthErrorMessage(String error) {
    switch (error.toLowerCase()) {
      case 'invalid login credentials':
        return 'Credenciales inválidas';
      case 'email not confirmed':
        return 'Email no confirmado';
      case 'user not found':
        return 'Usuario no encontrado';
      case 'invalid email':
        return 'Email inválido';
      case 'weak password':
        return 'Contraseña muy débil';
      case 'email already registered':
        return 'Email ya registrado';
      default:
        return error;
    }
  }
}

// Clase para resultados de autenticación
class AuthResult {
  final bool success;
  final String message;

  AuthResult._(this.success, this.message);

  factory AuthResult.success(String message) => AuthResult._(true, message);
  factory AuthResult.error(String message) => AuthResult._(false, message);
}
