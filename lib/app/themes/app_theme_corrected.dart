import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';
import 'theme_config.dart';

class AppTheme {
  AppTheme._();

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: ThemeConfig.useMaterial3,
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      
      // Extensiones personalizadas
      extensions: const [
        CustomThemeExtension.light,
      ],
      
      // Configuración de fuentes
      fontFamily: 'Inter',
      textTheme: _buildTextTheme(AppColors.lightColorScheme),
      
      // Configuración de AppBar
      appBarTheme: AppBarTheme(
        elevation: ThemeConfig.appBarElevation,
        centerTitle: true,
        backgroundColor: AppColors.lightColorScheme.surface,
        foregroundColor: AppColors.lightColorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.lightColorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: AppColors.lightColorScheme.onSurface,
          size: AppDimensions.iconM,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.lightColorScheme.onSurface,
          size: AppDimensions.iconM,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      // Configuración de BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.lightColorScheme.surface,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.neutral400,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      
      // Configuración de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.neutral900,
          elevation: ThemeConfig.defaultElevation,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.buttonBorderRadius),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          side: BorderSide(color: AppColors.primaryGold),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.buttonBorderRadius),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Configuración de campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral600,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral400,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.errorRed,
        ),
      ),
      
      // Configuración de tarjetas
      cardTheme: CardTheme(
        elevation: ThemeConfig.cardElevation,
        color: AppColors.lightColorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.cardBorderRadius),
        ),
        margin: const EdgeInsets.all(AppDimensions.spacing8),
      ),
      
      // Configuración de chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primaryGold.withValues(alpha: 0.2),
        disabledColor: AppColors.neutral200,
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primaryGold,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingS,
          vertical: AppDimensions.paddingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
      
      // Configuración de diálogos
      dialogTheme: DialogTheme(
        elevation: ThemeConfig.dialogElevation,
        backgroundColor: AppColors.lightColorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.lightColorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightColorScheme.onSurface,
        ),
      ),
      
      // Configuración de SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: ThemeConfig.cardElevation,
      ),
      
      // Configuración de FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.neutral900,
        elevation: ThemeConfig.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
      
      // Configuración de Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold.withValues(alpha: 0.5);
          }
          return AppColors.neutral300;
        }),
      ),
      
      // Configuración de Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.neutral900),
        side: BorderSide(color: AppColors.neutral400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        ),
      ),
      
      // Configuración de Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.neutral400;
        }),
      ),
      
      // Configuración de ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryGold,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: AppColors.neutral200,
      ),
      
      // Configuración de Divider
      dividerTheme: DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: AppDimensions.spacing16,
      ),
      
      // Configuración de ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.lightColorScheme.onSurface,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral600,
        ),
        iconColor: AppColors.neutral600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
      
      // Configuraciones adicionales
      splashFactory: ThemeConfig.splashFactory,
      pageTransitionsTheme: ThemeConfig.pageTransitionsTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  // Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: ThemeConfig.useMaterial3,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      
      // Extensiones personalizadas
      extensions: const [
        CustomThemeExtension.dark,
      ],
      
      // Configuración de fuentes
      fontFamily: 'Inter',
      textTheme: _buildTextTheme(AppColors.darkColorScheme),
      
      // Configuración de AppBar
      appBarTheme: AppBarTheme(
        elevation: ThemeConfig.appBarElevation,
        centerTitle: true,
        backgroundColor: AppColors.darkColorScheme.surface,
        foregroundColor: AppColors.darkColorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkColorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: AppColors.darkColorScheme.onSurface,
          size: AppDimensions.iconM,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.darkColorScheme.onSurface,
          size: AppDimensions.iconM,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Configuración de BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.darkColorScheme.surface,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.neutral400,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      
      // Configuración de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.neutral900,
          elevation: ThemeConfig.defaultElevation,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.buttonBorderRadius),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          side: BorderSide(color: AppColors.primaryGold),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.buttonBorderRadius),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Configuración de campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.neutral600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.neutral600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral400,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral500,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.errorRed,
        ),
      ),
      
      // Configuración de tarjetas
      cardTheme: CardTheme(
        elevation: ThemeConfig.cardElevation,
        color: AppColors.darkColorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.cardBorderRadius),
        ),
        margin: const EdgeInsets.all(AppDimensions.spacing8),
      ),
      
      // Configuración de chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral800,
        selectedColor: AppColors.primaryGold.withValues(alpha: 0.3),
        disabledColor: AppColors.neutral700,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkColorScheme.onSurface,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primaryGold,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingS,
          vertical: AppDimensions.paddingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
      
      // Configuración de diálogos
      dialogTheme: DialogTheme(
        elevation: ThemeConfig.dialogElevation,
        backgroundColor: AppColors.darkColorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkColorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkColorScheme.onSurface,
        ),
      ),
      
      // Configuración de SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral200,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: ThemeConfig.cardElevation,
      ),
      
      // Configuración de FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.neutral900,
        elevation: ThemeConfig.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
      
      // Configuración de Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.neutral500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold.withValues(alpha: 0.5);
          }
          return AppColors.neutral600;
        }),
      ),
      
      // Configuración de Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.neutral900),
        side: BorderSide(color: AppColors.neutral500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        ),
      ),
      
      // Configuración de Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.neutral600;
        }),
      ),
      
      // Configuración de ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryGold,
        linearTrackColor: AppColors.neutral700,
        circularTrackColor: AppColors.neutral700,
      ),
      
      // Configuración de Divider
      dividerTheme: DividerThemeData(
        color: AppColors.neutral700,
        thickness: 1,
        space: AppDimensions.spacing16,
      ),
      
      // Configuración de ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkColorScheme.onSurface,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral400,
        ),
        iconColor: AppColors.neutral400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
      
      // Configuraciones adicionales
      splashFactory: ThemeConfig.splashFactory,
      pageTransitionsTheme: ThemeConfig.pageTransitionsTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  // Construir TextTheme personalizado
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: colorScheme.onSurface),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: colorScheme.onSurface),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: colorScheme.onSurface),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: colorScheme.onSurface),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: colorScheme.onSurface),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: colorScheme.onSurface),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurface),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurface),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurface),
    );
  }
}

// Extensión personalizada del tema
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color? goldAccent;
  final Color? successGreen;
  final Color? warningOrange;
  final Color? infoBlue;
  final LinearGradient? primaryGradient;
  final LinearGradient? goldGradient;

  const CustomThemeExtension({
    this.goldAccent,
    this.successGreen,
    this.warningOrange,
    this.infoBlue,
    this.primaryGradient,
    this.goldGradient,
  });

  static const light = CustomThemeExtension(
    goldAccent: AppColors.primaryGold,
    successGreen: AppColors.successGreen,
    warningOrange: AppColors.warningOrange,
    infoBlue: AppColors.infoBlue,
    primaryGradient: AppColors.primaryGradient,
    goldGradient: AppColors.goldGradient,
  );

  static const dark = CustomThemeExtension(
    goldAccent: AppColors.primaryGold,
    successGreen: AppColors.successGreen,
    warningOrange: AppColors.warningOrange,
    infoBlue: AppColors.infoBlue,
    primaryGradient: AppColors.primaryGradient,
    goldGradient: AppColors.goldGradient,
  );

  @override
  CustomThemeExtension copyWith({
    Color? goldAccent,
    Color? successGreen,
    Color? warningOrange,
    Color? infoBlue,
    LinearGradient? primaryGradient,
    LinearGradient? goldGradient,
  }) {
    return CustomThemeExtension(
      goldAccent: goldAccent ?? this.goldAccent,
      successGreen: successGreen ?? this.successGreen,
      warningOrange: warningOrange ?? this.warningOrange,
      infoBlue: infoBlue ?? this.infoBlue,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      goldGradient: goldGradient ?? this.goldGradient,
    );
  }

  @override
  CustomThemeExtension lerp(CustomThemeExtension? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t),
      successGreen: Color.lerp(successGreen, other.successGreen, t),
      warningOrange: Color.lerp(warningOrange, other.warningOrange, t),
      infoBlue: Color.lerp(infoBlue, other.infoBlue, t),
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t),
      goldGradient: LinearGradient.lerp(goldGradient, other.goldGradient, t),
    );
  }
} 