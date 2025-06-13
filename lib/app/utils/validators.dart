import 'constants.dart';

/// Clase con validadores para formularios
class Validators {
  /// Valida que el campo no esté vacío
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es obligatorio';
    }
    return null;
  }
  
  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final RegExp emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }
  
  /// Valida formato de teléfono
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final RegExp phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un teléfono válido';
    }
    return null;
  }
  
  /// Valida contraseña segura
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    final RegExp passwordRegex = RegExp(AppConstants.passwordPattern);
    if (!passwordRegex.hasMatch(value)) {
      return 'La contraseña debe contener al menos:\n• Una mayúscula\n• Una minúscula\n• Un número';
    }
    return null;
  }
  
  /// Valida confirmación de contraseña
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
  
  /// Valida longitud mínima
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }
    return null;
  }
  
  /// Valida longitud máxima
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} no puede tener más de $maxLength caracteres';
    }
    return null;
  }
  
  /// Valida que sea un número
  static String? numeric(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;
    
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }
    return null;
  }
  
  /// Valida rango numérico
  static String? numericRange(String? value, double min, double max, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;
    
    final number = double.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }
    
    if (number < min || number > max) {
      return '${fieldName ?? 'Este campo'} debe estar entre $min y $max';
    }
    return null;
  }
  
  /// Valida monto de depósito
  static String? depositAmount(String? value) {
    final numericError = numeric(value, 'El monto');
    if (numericError != null) return numericError;
    
    final amount = double.parse(value!);
    if (amount < 5.0) {
      return 'El monto mínimo es €5.00';
    }
    if (amount > 500.0) {
      return 'El monto máximo es €500.00';
    }
    return null;
  }
  
  /// Valida nombre completo
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 50) {
      return 'El nombre no puede tener más de 50 caracteres';
    }
    
    // Verificar que contenga al menos dos palabras
    final words = value.trim().split(' ').where((word) => word.isNotEmpty).toList();
    if (words.length < 2) {
      return 'Ingresa tu nombre y apellido';
    }
    
    return null;
  }
  
  /// Combina múltiples validadores
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
} 