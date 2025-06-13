import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../themes/app_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  // Storage para persistir las preferencias
  final _storage = GetStorage();
  
  // Clave para almacenar el tema
  static const String _themeKey = 'app_theme';
  static const String _systemThemeKey = 'use_system_theme';
  
  // Variables reactivas
  final _isDarkMode = false.obs;
  final _useSystemTheme = true.obs;
  
  // Getters
  bool get isDarkMode => _isDarkMode.value;
  bool get useSystemTheme => _useSystemTheme.value;
  ThemeMode get themeMode {
    if (_useSystemTheme.value) {
      return ThemeMode.system;
    }
    return _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  }
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
    _listenToSystemTheme();
  }
  
  // Cargar tema desde storage
  void _loadThemeFromStorage() {
    try {
      final useSystem = _storage.read(_systemThemeKey) ?? true;
      final isDark = _storage.read(_themeKey) ?? false;
      
      _useSystemTheme.value = useSystem;
      _isDarkMode.value = isDark;
      
      // Si usa tema del sistema, detectar el tema actual
      if (useSystem) {
        _detectSystemTheme();
      }
      
      // Aplicar el tema
      _applyTheme();
    } catch (e) {
      // En caso de error, usar valores por defecto
      _useSystemTheme.value = true;
      _isDarkMode.value = false;
      _detectSystemTheme();
      _applyTheme();
    }
  }
  
  // Detectar tema del sistema
  void _detectSystemTheme() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode.value = brightness == Brightness.dark;
  }
  
  // Escuchar cambios en el tema del sistema
  void _listenToSystemTheme() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_useSystemTheme.value) {
        _detectSystemTheme();
        _applyTheme();
      }
    };
  }
  
  // Aplicar tema
  void _applyTheme() {
    Get.changeThemeMode(themeMode);
  }
  
  // Guardar preferencias en storage
  void _saveThemeToStorage() {
    try {
      _storage.write(_systemThemeKey, _useSystemTheme.value);
      _storage.write(_themeKey, _isDarkMode.value);
    } catch (e) {
      // Manejar error de escritura
      debugPrint('Error saving theme preferences: $e');
    }
  }
  
  // Cambiar entre tema claro y oscuro
  void toggleTheme() {
    _useSystemTheme.value = false;
    _isDarkMode.value = !_isDarkMode.value;
    _saveThemeToStorage();
    _applyTheme();
  }
  
  // Establecer tema específico
  void setTheme(bool isDark) {
    _useSystemTheme.value = false;
    _isDarkMode.value = isDark;
    _saveThemeToStorage();
    _applyTheme();
  }
  
  // Usar tema del sistema
  void enableSystemTheme() {
    _useSystemTheme.value = true;
    _detectSystemTheme();
    _saveThemeToStorage();
    _applyTheme();
  }
  
  // Usar tema claro
  void setLightTheme() {
    setTheme(false);
  }
  
  // Usar tema oscuro
  void setDarkTheme() {
    setTheme(true);
  }
  
  // Obtener el tema actual
  ThemeData getCurrentTheme() {
    return _isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
  
  // Obtener el esquema de colores actual
  ColorScheme getCurrentColorScheme() {
    return getCurrentTheme().colorScheme;
  }
  
  // Obtener el tema de texto actual
  TextTheme getCurrentTextTheme() {
    return getCurrentTheme().textTheme;
  }
  
  // Métodos de utilidad para obtener colores específicos
  Color get primaryColor => getCurrentColorScheme().primary;
  Color get secondaryColor => getCurrentColorScheme().secondary;
  Color get backgroundColor => getCurrentColorScheme().background;
  Color get surfaceColor => getCurrentColorScheme().surface;
  Color get errorColor => getCurrentColorScheme().error;
  
  Color get onPrimaryColor => getCurrentColorScheme().onPrimary;
  Color get onSecondaryColor => getCurrentColorScheme().onSecondary;
  Color get onBackgroundColor => getCurrentColorScheme().onBackground;
  Color get onSurfaceColor => getCurrentColorScheme().onSurface;
  Color get onErrorColor => getCurrentColorScheme().onError;
  
  // Métodos para obtener información del tema
  String get currentThemeName {
    if (_useSystemTheme.value) {
      return 'Sistema';
    }
    return _isDarkMode.value ? 'Oscuro' : 'Claro';
  }
  
  IconData get currentThemeIcon {
    if (_useSystemTheme.value) {
      return Icons.brightness_auto;
    }
    return _isDarkMode.value ? Icons.dark_mode : Icons.light_mode;
  }
  
  // Método para reiniciar tema a valores por defecto
  void resetTheme() {
    _useSystemTheme.value = true;
    _detectSystemTheme();
    _saveThemeToStorage();
    _applyTheme();
  }
  
  // Método para obtener el contraste del tema actual
  bool get isHighContrast {
    final colorScheme = getCurrentColorScheme();
    final primaryLuminance = colorScheme.primary.computeLuminance();
    final backgroundLuminance = colorScheme.background.computeLuminance();
    
    final contrast = (primaryLuminance + 0.05) / (backgroundLuminance + 0.05);
    return contrast > 4.5; // WCAG AA standard
  }
  
  // Método para obtener un color con opacidad basado en el tema
  Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Método para obtener un color adaptativo basado en el tema
  Color getAdaptiveColor({
    required Color lightColor,
    required Color darkColor,
  }) {
    return _isDarkMode.value ? darkColor : lightColor;
  }
  
  // Método para obtener el color de texto adaptativo
  Color getAdaptiveTextColor() {
    return _isDarkMode.value ? Colors.white : Colors.black;
  }
  
  // Método para obtener el color de fondo adaptativo
  Color getAdaptiveBackgroundColor() {
    return _isDarkMode.value ? Colors.black : Colors.white;
  }
  
  // Método para verificar si el tema actual es compatible con una característica
  bool supportsFeature(String feature) {
    switch (feature) {
      case 'material3':
        return true;
      case 'dynamic_colors':
        return true;
      case 'high_contrast':
        return isHighContrast;
      default:
        return false;
    }
  }
  
  // Método para obtener información de debug del tema
  Map<String, dynamic> getThemeDebugInfo() {
    return {
      'isDarkMode': _isDarkMode.value,
      'useSystemTheme': _useSystemTheme.value,
      'themeMode': themeMode.toString(),
      'currentThemeName': currentThemeName,
      'isHighContrast': isHighContrast,
      'primaryColor': primaryColor.toString(),
      'backgroundColor': backgroundColor.toString(),
    };
  }
} 