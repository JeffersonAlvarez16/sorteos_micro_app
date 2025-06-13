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
          size: AppDimensions.iconMedium,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.lightColorScheme.onSurface,
          size: AppDimensions.iconMedium,
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
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
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
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
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
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
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
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral600,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral400,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
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
        margin: const EdgeInsets.all(AppDimensions.spacingSmall),
      ),
      
      // Configuración de chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primaryGold.withOpacity(0.2),
        disabledColor: AppColors.neutral200,
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primaryGold,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingExtraSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
      
      // Configuración de diálogos
      dialogTheme: DialogTheme(
        elevation: ThemeConfig.dialogElevation,
        backgroundColor: AppColors.lightColorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      
      // Configuración de Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.neutral400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryGold.withOpacity(0.5);
          }
          return AppColors.neutral300;
        }),
      ),
      
      // Configuración de Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryGold;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.neutral900),
        side: BorderSide(color: AppColors.neutral400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraSmall),
        ),
      ),
      
      // Configuración de Radio
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
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
        space: AppDimensions.spacingMedium,
      ),
      
      // Configuración de ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.lightColorScheme.onSurface,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral600,
        ),
        iconColor: AppColors.neutral600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
      
      // Configuraciones adicionales
      splashFactory: ThemeConfig.splashFactory,
      pageTransitionsTheme: ThemeConfig.pageTransitionsTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.adaptivePlatformDensity,
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
          size: AppDimensions.iconMedium,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.darkColorScheme.onSurface,
          size: AppDimensions.iconMedium,
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
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
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
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
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
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
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
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral400,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral500,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
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
        margin: const EdgeInsets.all(AppDimensions.spacingSmall),
      ),
      
      // Configuración de chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral800,
        selectedColor: AppColors.primaryGold.withOpacity(0.3),
        disabledColor: AppColors.neutral700,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkColorScheme.onSurface,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primaryGold,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingExtraSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
      
      // Configuración de diálogos
      dialogTheme: DialogTheme(
        elevation: ThemeConfig.dialogElevation,
        backgroundColor: AppColors.darkColorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      
      // Configuración de Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.neutral500;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryGold.withOpacity(0.5);
          }
          return AppColors.neutral600;
        }),
      ),
      
      // Configuración de Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryGold;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.neutral900),
        side: BorderSide(color: AppColors.neutral500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraSmall),
        ),
      ),
      
      // Configuración de Radio
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.neutral500;
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
        space: AppDimensions.spacingMedium,
      ),
      
      // Configuración de ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkColorScheme.onSurface,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral400,
        ),
        iconColor: AppColors.neutral400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
      
      // Configuraciones adicionales
      splashFactory: ThemeConfig.splashFactory,
      pageTransitionsTheme: ThemeConfig.pageTransitionsTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.adaptivePlatformDensity,
    );
  }

  // Construir tema de texto personalizado
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }
} 