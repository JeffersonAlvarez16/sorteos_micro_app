import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Fuente principal de la aplicación
  static String get _fontFamily => GoogleFonts.inter().fontFamily!;
  
  // Fuente para títulos y encabezados
  static String get _headingFontFamily => GoogleFonts.poppins().fontFamily!;
  
  // Fuente para números y estadísticas
  static String get _numberFontFamily => GoogleFonts.robotoMono().fontFamily!;
  
  // Configuración base de texto
  static const double _baseLineHeight = 1.4;
  static const double _headingLineHeight = 1.2;
  static const double _compactLineHeight = 1.1;
  
  // Display Styles - Para títulos muy grandes
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: _headingLineHeight,
    letterSpacing: -0.25,
  );
  
  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: _headingLineHeight,
    letterSpacing: 0,
  );
  
  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: _headingLineHeight,
    letterSpacing: 0,
  );
  
  // Headline Styles - Para títulos principales
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: _headingLineHeight,
    letterSpacing: 0,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: _headingLineHeight,
    letterSpacing: 0,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: _headingLineHeight,
    letterSpacing: 0,
  );
  
  // Title Styles - Para títulos de secciones
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: _baseLineHeight,
    letterSpacing: 0,
  );
  
  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: _baseLineHeight,
    letterSpacing: 0.15,
  );
  
  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: _baseLineHeight,
    letterSpacing: 0.1,
  );
  
  // Label Styles - Para etiquetas y botones
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0.1,
  );
  
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0.5,
  );
  
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0.5,
  );
  
  // Body Styles - Para texto de contenido
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: _baseLineHeight,
    letterSpacing: 0.15,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: _baseLineHeight,
    letterSpacing: 0.25,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: _baseLineHeight,
    letterSpacing: 0.4,
  );
  
  // Estilos específicos para la aplicación de sorteos
  
  // Para mostrar precios y cantidades monetarias
  static TextStyle get priceStyle => GoogleFonts.robotoMono(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: _compactLineHeight,
    letterSpacing: -0.5,
  );
  
  static TextStyle get priceLargeStyle => GoogleFonts.robotoMono(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: _compactLineHeight,
    letterSpacing: -0.5,
  );
  
  static TextStyle get priceSmallStyle => GoogleFonts.robotoMono(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0,
  );
  
  // Para números de estadísticas
  static TextStyle get statNumberStyle => GoogleFonts.robotoMono(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: _compactLineHeight,
    letterSpacing: -0.25,
  );
  
  static TextStyle get statNumberLargeStyle => GoogleFonts.robotoMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: _compactLineHeight,
    letterSpacing: -0.5,
  );
  
  // Para countdown y tiempo restante
  static TextStyle get countdownStyle => GoogleFonts.robotoMono(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0.5,
  );
  
  static TextStyle get countdownLargeStyle => GoogleFonts.robotoMono(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: _compactLineHeight,
    letterSpacing: 0.5,
  );
  
  // Para badges y etiquetas de estado
  static TextStyle get badgeStyle => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: _compactLineHeight,
    letterSpacing: 0.5,
  );
  
  static TextStyle get badgeMediumStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0.4,
  );
  
  // Para texto de ayuda y descripciones
  static TextStyle get captionStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: _baseLineHeight,
    letterSpacing: 0.4,
  );
  
  static TextStyle get overlineStyle => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: _compactLineHeight,
    letterSpacing: 1.5,
  );
  
  // Para texto de error y validación
  static TextStyle get errorStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: _baseLineHeight,
    letterSpacing: 0.4,
  );
  
  // Para texto de éxito
  static TextStyle get successStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: _baseLineHeight,
    letterSpacing: 0.4,
  );
  
  // Para texto de advertencia
  static TextStyle get warningStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: _baseLineHeight,
    letterSpacing: 0.4,
  );
  
  // Para enlaces
  static TextStyle get linkStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: _baseLineHeight,
    letterSpacing: 0.25,
    decoration: TextDecoration.underline,
  );
  
  // Para texto de botones
  static TextStyle get buttonTextStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0.1,
  );
  
  static TextStyle get buttonTextLargeStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0.1,
  );
  
  static TextStyle get buttonTextSmallStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: _compactLineHeight,
    letterSpacing: 0.5,
  );
  
  // Para texto de navegación
  static TextStyle get navLabelStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: _compactLineHeight,
    letterSpacing: 0.4,
  );
  
  // Para texto de formularios
  static TextStyle get inputLabelStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: _baseLineHeight,
    letterSpacing: 0.25,
  );
  
  static TextStyle get inputTextStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: _baseLineHeight,
    letterSpacing: 0.15,
  );
  
  static TextStyle get inputHintStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: _baseLineHeight,
    letterSpacing: 0.15,
  );
  
  // Para texto de diálogos
  static TextStyle get dialogTitleStyle => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: _headingLineHeight,
    letterSpacing: 0,
  );
  
  static TextStyle get dialogContentStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: _baseLineHeight,
    letterSpacing: 0.25,
  );
  
  // TextTheme completo para usar en el tema de la aplicación
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );
  
  // Métodos de utilidad para aplicar colores a los estilos
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }
  
  // Estilos con variaciones de peso
  static TextStyle light(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w300);
  }
  
  static TextStyle regular(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w400);
  }
  
  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }
  
  static TextStyle semiBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }
  
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }
  
  static TextStyle extraBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w800);
  }
  
  // Estilos con variaciones de tamaño
  static TextStyle larger(TextStyle style, {double factor = 1.2}) {
    return style.copyWith(fontSize: (style.fontSize ?? 14) * factor);
  }
  
  static TextStyle smaller(TextStyle style, {double factor = 0.8}) {
    return style.copyWith(fontSize: (style.fontSize ?? 14) * factor);
  }
} 