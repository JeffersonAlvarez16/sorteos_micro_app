import 'package:flutter/material.dart';

class AppDimensions {
  // Espaciados base
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;
  
  // Espaciados específicos
  static const double paddingXS = spacing4;
  static const double paddingS = spacing8;
  static const double paddingM = spacing16;
  static const double paddingL = spacing24;
  static const double paddingXL = spacing32;
  static const double paddingXXL = spacing48;
  
  // Márgenes
  static const double marginXS = spacing4;
  static const double marginS = spacing8;
  static const double marginM = spacing16;
  static const double marginL = spacing24;
  static const double marginXL = spacing32;
  static const double marginXXL = spacing48;
  
  // Radios de borde
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 50.0;
  
  // Elevaciones
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
  
  // Alturas de componentes
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 56.0;
  
  static const double textFieldHeight = 56.0;
  static const double textFieldHeightS = 40.0;
  static const double textFieldHeightL = 64.0;
  
  static const double appBarHeight = 56.0;
  static const double appBarHeightL = 64.0;
  static const double bottomNavHeight = 60.0;
  
  static const double cardMinHeight = 120.0;
  static const double cardMaxHeight = 300.0;
  
  static const double listItemHeight = 72.0;
  static const double listItemHeightS = 56.0;
  static const double listItemHeightL = 88.0;
  
  // Anchos de componentes
  static const double buttonMinWidth = 88.0;
  static const double buttonMaxWidth = 280.0;
  
  static const double dialogMinWidth = 280.0;
  static const double dialogMaxWidth = 560.0;
  
  static const double sidebarWidth = 280.0;
  static const double sidebarWidthCollapsed = 72.0;
  
  // Tamaños de iconos
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;
  
  // Tamaños de avatares
  static const double avatarXS = 24.0;
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 56.0;
  static const double avatarXL = 72.0;
  static const double avatarXXL = 96.0;
  
  // Tamaños específicos para la aplicación de sorteos
  
  // Tarjetas de sorteo
  static const double raffleCardHeight = 200.0;
  static const double raffleCardMinHeight = 160.0;
  static const double raffleCardMaxHeight = 240.0;
  static const double raffleCardImageHeight = 120.0;
  
  // Tarjetas de depósito
  static const double depositCardHeight = 140.0;
  static const double depositCardMinHeight = 120.0;
  
  // Tarjetas de estadísticas
  static const double statCardHeight = 100.0;
  static const double statCardMinHeight = 80.0;
  static const double statCardWidth = 160.0;
  
  // Componentes de formulario
  static const double formSectionSpacing = spacing24;
  static const double formFieldSpacing = spacing16;
  static const double formGroupSpacing = spacing32;
  
  // Componentes de navegación
  static const double tabHeight = 48.0;
  static const double tabMinWidth = 90.0;
  
  // Componentes de loading
  static const double loadingIndicatorS = 16.0;
  static const double loadingIndicatorM = 24.0;
  static const double loadingIndicatorL = 32.0;
  static const double loadingIndicatorXL = 48.0;
  
  // Componentes de progreso
  static const double progressBarHeight = 8.0;
  static const double progressBarHeightL = 12.0;
  static const double progressBarRadius = 4.0;
  
  // Componentes de slider
  static const double sliderHeight = 40.0;
  static const double sliderThumbRadius = 12.0;
  static const double sliderTrackHeight = 4.0;
  
  // Componentes de switch
  static const double switchWidth = 52.0;
  static const double switchHeight = 32.0;
  static const double switchThumbSize = 20.0;
  
  // Componentes de checkbox y radio
  static const double checkboxSize = 20.0;
  static const double radioSize = 20.0;
  
  // Breakpoints para responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  static const double largeDesktopBreakpoint = 1600.0;
  
  // Anchos máximos para contenido
  static const double maxContentWidth = 1200.0;
  static const double maxFormWidth = 400.0;
  static const double maxCardWidth = 600.0;
  
  // Espaciados para diferentes tamaños de pantalla
  static const double mobileHorizontalPadding = spacing16;
  static const double tabletHorizontalPadding = spacing24;
  static const double desktopHorizontalPadding = spacing32;
  
  static const double mobileVerticalPadding = spacing16;
  static const double tabletVerticalPadding = spacing24;
  static const double desktopVerticalPadding = spacing32;
  
  // Duraciones de animación
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration animationDurationVerySlow = Duration(milliseconds: 800);
  
  // Curvas de animación más utilizadas
  static const Curve animationCurveStandard = Curves.easeInOut;
  static const Curve animationCurveDecelerate = Curves.easeOut;
  static const Curve animationCurveAccelerate = Curves.easeIn;
  static const Curve animationCurveBounce = Curves.bounceOut;
  
  // Opacidades estándar
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityOverlay = 0.16;
  static const double opacityDivider = 0.12;
  
  // Métodos de utilidad para obtener dimensiones responsivas
  static double getHorizontalPadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return mobileHorizontalPadding;
    } else if (screenWidth < tabletBreakpoint) {
      return tabletHorizontalPadding;
    } else {
      return desktopHorizontalPadding;
    }
  }
  
  static double getVerticalPadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return mobileVerticalPadding;
    } else if (screenWidth < tabletBreakpoint) {
      return tabletVerticalPadding;
    } else {
      return desktopVerticalPadding;
    }
  }
  
  static int getGridColumns(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return 1;
    } else if (screenWidth < tabletBreakpoint) {
      return 2;
    } else if (screenWidth < desktopBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }
  
  static double getCardWidth(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return screenWidth - (mobileHorizontalPadding * 2);
    } else if (screenWidth < tabletBreakpoint) {
      return (screenWidth - (tabletHorizontalPadding * 3)) / 2;
    } else {
      return maxCardWidth;
    }
  }
} 