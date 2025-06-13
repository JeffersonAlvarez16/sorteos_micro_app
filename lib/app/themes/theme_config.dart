import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// Configuración de temas personalizada para la aplicación
class ThemeConfig {
  ThemeConfig._();
  
  // Configuraciones de Material 3
  static const bool useMaterial3 = true;
  
  // Configuraciones de animación
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // Configuraciones de elevación
  static const double defaultElevation = 2.0;
  static const double cardElevation = 4.0;
  static const double dialogElevation = 8.0;
  static const double appBarElevation = 0.0;
  
  // Configuraciones de bordes
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 8.0;
  static const double inputBorderRadius = 8.0;
  
  // Configuraciones de opacidad
  static const double disabledOpacity = 0.38;
  static const double hoverOpacity = 0.04;
  static const double focusOpacity = 0.12;
  static const double pressedOpacity = 0.12;
  static const double selectedOpacity = 0.08;
  
  // Configuraciones de sombras
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Configuraciones de gradientes
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [
      AppColors.primaryGold,
      AppColors.primaryGold.withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get secondaryGradient => LinearGradient(
    colors: [
      AppColors.primaryBlue,
      AppColors.primaryBlue.withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get successGradient => LinearGradient(
    colors: [
      AppColors.successGreen,
      AppColors.successGreen.withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get errorGradient => LinearGradient(
    colors: [
      AppColors.errorRed,
      AppColors.errorRed.withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Configuraciones de vibración háptica
  static void lightHaptic() => HapticFeedback.lightImpact();
  static void mediumHaptic() => HapticFeedback.mediumImpact();
  static void heavyHaptic() => HapticFeedback.heavyImpact();
  static void selectionHaptic() => HapticFeedback.selectionClick();
  
  // Configuraciones de transiciones
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve fastCurve = Curves.easeOut;
  static const Curve slowCurve = Curves.easeInOutCubic;
  
  // Configuraciones de página
  static PageTransitionsTheme get pageTransitionsTheme => const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    },
  );
  
  // Configuraciones de splash
  static InteractiveInkFeatureFactory get splashFactory => InkRipple.splashFactory;
  
  // Configuraciones de scroll
  static ScrollBehavior get scrollBehavior => const MaterialScrollBehavior().copyWith(
    scrollbars: false,
    overscroll: false,
    physics: const BouncingScrollPhysics(),
  );
}

/// Extensión de tema personalizada
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  const CustomThemeExtension({
    required this.raffleCardColor,
    required this.depositCardColor,
    required this.statisticCardColor,
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
    required this.goldColor,
    required this.silverColor,
    required this.bronzeColor,
    required this.gradientPrimary,
    required this.gradientSecondary,
    required this.overlayColor,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
  });
  
  final Color raffleCardColor;
  final Color depositCardColor;
  final Color statisticCardColor;
  final Color successColor;
  final Color warningColor;
  final Color infoColor;
  final Color goldColor;
  final Color silverColor;
  final Color bronzeColor;
  final LinearGradient gradientPrimary;
  final LinearGradient gradientSecondary;
  final Color overlayColor;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;
  
  @override
  CustomThemeExtension copyWith({
    Color? raffleCardColor,
    Color? depositCardColor,
    Color? statisticCardColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? goldColor,
    Color? silverColor,
    Color? bronzeColor,
    LinearGradient? gradientPrimary,
    LinearGradient? gradientSecondary,
    Color? overlayColor,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) {
    return CustomThemeExtension(
      raffleCardColor: raffleCardColor ?? this.raffleCardColor,
      depositCardColor: depositCardColor ?? this.depositCardColor,
      statisticCardColor: statisticCardColor ?? this.statisticCardColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      goldColor: goldColor ?? this.goldColor,
      silverColor: silverColor ?? this.silverColor,
      bronzeColor: bronzeColor ?? this.bronzeColor,
      gradientPrimary: gradientPrimary ?? this.gradientPrimary,
      gradientSecondary: gradientSecondary ?? this.gradientSecondary,
      overlayColor: overlayColor ?? this.overlayColor,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor ?? this.shimmerHighlightColor,
    );
  }
  
  @override
  CustomThemeExtension lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    
    return CustomThemeExtension(
      raffleCardColor: Color.lerp(raffleCardColor, other.raffleCardColor, t)!,
      depositCardColor: Color.lerp(depositCardColor, other.depositCardColor, t)!,
      statisticCardColor: Color.lerp(statisticCardColor, other.statisticCardColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      goldColor: Color.lerp(goldColor, other.goldColor, t)!,
      silverColor: Color.lerp(silverColor, other.silverColor, t)!,
      bronzeColor: Color.lerp(bronzeColor, other.bronzeColor, t)!,
      gradientPrimary: LinearGradient.lerp(gradientPrimary, other.gradientPrimary, t)!,
      gradientSecondary: LinearGradient.lerp(gradientSecondary, other.gradientSecondary, t)!,
      overlayColor: Color.lerp(overlayColor, other.overlayColor, t)!,
      shimmerBaseColor: Color.lerp(shimmerBaseColor, other.shimmerBaseColor, t)!,
      shimmerHighlightColor: Color.lerp(shimmerHighlightColor, other.shimmerHighlightColor, t)!,
    );
  }
  
  // Extensión para tema claro
  static const CustomThemeExtension light = CustomThemeExtension(
    raffleCardColor: Color(0xFFFFFBF0),
    depositCardColor: Color(0xFFF0F8FF),
    statisticCardColor: Color(0xFFF8F9FA),
    successColor: AppColors.successGreen,
    warningColor: AppColors.warningOrange,
    infoColor: AppColors.infoBlue,
    goldColor: AppColors.primaryGold,
    silverColor: Color(0xFFC0C0C0),
    bronzeColor: Color(0xFFCD7F32),
    gradientPrimary: LinearGradient(
      colors: [AppColors.primaryGold, Color(0xFFFFE55C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientSecondary: LinearGradient(
      colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    overlayColor: Color(0x80000000),
    shimmerBaseColor: Color(0xFFE0E0E0),
    shimmerHighlightColor: Color(0xFFF5F5F5),
  );
  
  // Extensión para tema oscuro
  static const CustomThemeExtension dark = CustomThemeExtension(
    raffleCardColor: Color(0xFF2A2A2A),
    depositCardColor: Color(0xFF1E2A3A),
    statisticCardColor: Color(0xFF252525),
    successColor: AppColors.successGreen,
    warningColor: AppColors.warningOrange,
    infoColor: AppColors.infoBlue,
    goldColor: AppColors.primaryGold,
    silverColor: Color(0xFFC0C0C0),
    bronzeColor: Color(0xFFCD7F32),
    gradientPrimary: LinearGradient(
      colors: [AppColors.primaryGold, Color(0xFFB8860B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientSecondary: LinearGradient(
      colors: [AppColors.primaryBlue, Color(0xFF1E40AF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    overlayColor: Color(0x80000000),
    shimmerBaseColor: Color(0xFF3A3A3A),
    shimmerHighlightColor: Color(0xFF4A4A4A),
  );
}

/// Utilidades de tema
class ThemeUtils {
  ThemeUtils._();
  
  // Obtener extensión personalizada del tema
  static CustomThemeExtension getCustomExtension(BuildContext context) {
    return Theme.of(context).extension<CustomThemeExtension>() ?? CustomThemeExtension.light;
  }
  
  // Verificar si es tema oscuro
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  // Obtener color adaptativo
  static Color getAdaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode(context) ? darkColor : lightColor;
  }
  
  // Obtener color con opacidad
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Obtener sombra adaptativa
  static List<BoxShadow> getAdaptiveShadow(BuildContext context) {
    return isDarkMode(context) 
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : ThemeConfig.defaultShadow;
  }
  
  // Obtener gradiente adaptativo
  static LinearGradient getAdaptiveGradient(
    BuildContext context, {
    required LinearGradient lightGradient,
    required LinearGradient darkGradient,
  }) {
    return isDarkMode(context) ? darkGradient : lightGradient;
  }
  
  // Obtener color de estado
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'activo':
        return AppColors.successGreen;
      case 'pending':
      case 'pendiente':
        return AppColors.warningOrange;
      case 'completed':
      case 'completado':
        return AppColors.infoBlue;
      case 'cancelled':
      case 'cancelado':
      case 'failed':
      case 'fallido':
        return AppColors.errorRed;
      default:
        return AppColors.neutral400;
    }
  }
  
  // Obtener icono de estado
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'activo':
        return Icons.play_circle_filled;
      case 'pending':
      case 'pendiente':
        return Icons.schedule;
      case 'completed':
      case 'completado':
        return Icons.check_circle;
      case 'cancelled':
      case 'cancelado':
        return Icons.cancel;
      case 'failed':
      case 'fallido':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }
  
  // Crear decoración de contenedor personalizada
  static BoxDecoration createContainerDecoration({
    required BuildContext context,
    Color? color,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color ?? Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(borderRadius ?? ThemeConfig.defaultBorderRadius),
      boxShadow: boxShadow ?? getAdaptiveShadow(context),
      border: border,
      gradient: gradient,
    );
  }
  
  // Crear estilo de botón personalizado
  static ButtonStyle createButtonStyle({
    required BuildContext context,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    BorderSide? side,
    OutlinedBorder? shape,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
      elevation: elevation ?? ThemeConfig.defaultElevation,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: minimumSize ?? const Size(88, 48),
      side: side,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.buttonBorderRadius),
      ),
    );
  }
  
  // Crear decoración de input personalizada
  static InputDecoration createInputDecoration({
    required BuildContext context,
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      enabled: enabled,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
        borderSide: BorderSide(
          color: Theme.of(context).disabledColor,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
} 