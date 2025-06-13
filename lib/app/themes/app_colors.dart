import 'package:flutter/material.dart';

class AppColors {
  // Colores primarios de la marca
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color accentGreen = Color(0xFF10B981);
  
  // Colores de estado
  static const Color successGreen = Color(0xFF059669);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color infoBlue = Color(0xFF3B82F6);
  
  // Grises neutros
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  
  // Colores específicos para sorteos
  static const Color raffleActive = Color(0xFF10B981);
  static const Color raffleCompleted = Color(0xFF3B82F6);
  static const Color raffleCancelled = Color(0xFFEF4444);
  static const Color rafflePending = Color(0xFFF59E0B);
  
  // Colores para depósitos
  static const Color depositApproved = Color(0xFF059669);
  static const Color depositPending = Color(0xFFF59E0B);
  static const Color depositRejected = Color(0xFFDC2626);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Esquema de colores claro
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    
    // Colores principales
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDEE7FF),
    onPrimaryContainer: Color(0xFF001B3D),
    
    // Colores secundarios
    secondary: secondaryPurple,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE9DDFF),
    onSecondaryContainer: Color(0xFF2A0845),
    
    // Colores terciarios
    tertiary: accentGreen,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFA7F3D0),
    onTertiaryContainer: Color(0xFF002114),
    
    // Colores de error
    error: errorRed,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    
    // Colores de superficie
    background: neutral50,
    onBackground: neutral900,
    surface: Colors.white,
    onSurface: neutral900,
    surfaceVariant: neutral100,
    onSurfaceVariant: neutral700,
    
    // Colores de contorno
    outline: neutral300,
    outlineVariant: neutral200,
    
    // Colores inversos
    inverseSurface: neutral800,
    onInverseSurface: neutral100,
    inversePrimary: Color(0xFF9BB3FF),
    
    // Colores de sombra y superficie tintada
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: primaryBlue,
  );
  
  // Esquema de colores oscuro
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    
    // Colores principales
    primary: Color(0xFF9BB3FF),
    onPrimary: Color(0xFF001B3D),
    primaryContainer: Color(0xFF002C5F),
    onPrimaryContainer: Color(0xFFDEE7FF),
    
    // Colores secundarios
    secondary: Color(0xFFCDB4FF),
    onSecondary: Color(0xFF2A0845),
    secondaryContainer: Color(0xFF41205E),
    onSecondaryContainer: Color(0xFFE9DDFF),
    
    // Colores terciarios
    tertiary: Color(0xFF6EE7B7),
    onTertiary: Color(0xFF002114),
    tertiaryContainer: Color(0xFF00391F),
    onTertiaryContainer: Color(0xFFA7F3D0),
    
    // Colores de error
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    
    // Colores de superficie
    background: Color(0xFF0F0F0F),
    onBackground: neutral100,
    surface: Color(0xFF1A1A1A),
    onSurface: neutral100,
    surfaceVariant: neutral800,
    onSurfaceVariant: neutral400,
    
    // Colores de contorno
    outline: neutral600,
    outlineVariant: neutral700,
    
    // Colores inversos
    inverseSurface: neutral100,
    onInverseSurface: neutral800,
    inversePrimary: primaryBlue,
    
    // Colores de sombra y superficie tintada
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Color(0xFF9BB3FF),
  );
  
  // Métodos de utilidad para obtener colores por estado
  static Color getRaffleStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return raffleActive;
      case 'completed':
        return raffleCompleted;
      case 'cancelled':
        return raffleCancelled;
      case 'pending':
        return rafflePending;
      default:
        return neutral500;
    }
  }
  
  static Color getDepositStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return depositApproved;
      case 'pending':
        return depositPending;
      case 'rejected':
        return depositRejected;
      default:
        return neutral500;
    }
  }
  
  static LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'approved':
      case 'active':
        return successGradient;
      case 'warning':
      case 'pending':
        return warningGradient;
      case 'error':
      case 'rejected':
      case 'cancelled':
        return errorGradient;
      default:
        return primaryGradient;
    }
  }
  
  // Colores con opacidad para overlays
  static Color get overlayLight => Colors.black.withOpacity(0.5);
  static Color get overlayDark => Colors.black.withOpacity(0.7);
  static Color get shimmerBase => neutral200;
  static Color get shimmerHighlight => neutral100;
  static Color get shimmerBaseDark => neutral800;
  static Color get shimmerHighlightDark => neutral700;
  
  // Colores para gráficos y estadísticas
  static const List<Color> chartColors = [
    primaryBlue,
    secondaryPurple,
    accentGreen,
    primaryGold,
    warningOrange,
    infoBlue,
    successGreen,
    errorRed,
  ];
  
  // Colores para diferentes tipos de notificaciones
  static const Color notificationSuccess = successGreen;
  static const Color notificationWarning = warningOrange;
  static const Color notificationError = errorRed;
  static const Color notificationInfo = infoBlue;
  
  // Colores para badges y etiquetas
  static const Color badgeNew = accentGreen;
  static const Color badgeHot = errorRed;
  static const Color badgePopular = primaryGold;
  static const Color badgeLimited = secondaryPurple;
} 