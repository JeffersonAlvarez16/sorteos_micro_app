import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Clase con funciones de utilidad generales
class AppHelpers {
  /// Formatea un monto de dinero
  static String formatCurrency(double amount, {String symbol = '€'}) {
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  /// Formatea un número con separadores de miles
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'es_ES');
    return formatter.format(number);
  }
  
  /// Formatea una fecha
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    final formatter = DateFormat(pattern, 'es_ES');
    return formatter.format(date);
  }
  
  /// Formatea una fecha con hora
  static String formatDateTime(DateTime dateTime, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    final formatter = DateFormat(pattern, 'es_ES');
    return formatter.format(dateTime);
  }
  
  /// Formatea tiempo relativo (hace 2 horas, hace 1 día, etc.)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora mismo';
    }
  }
  
  /// Calcula el tiempo restante hasta una fecha
  static String formatTimeRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    
    if (difference.isNegative) {
      return 'Finalizado';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  /// Genera un color basado en un string
  static Color generateColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final hue = (hash % 360).abs().toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.8).toColor();
  }
  
  /// Obtiene las iniciales de un nombre
  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }
  
  /// Copia texto al portapapeles
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
  
  /// Abre una URL en el navegador
  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
  
  /// Abre el marcador de teléfono
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    return await launchUrl(uri);
  }
  
  /// Abre el cliente de email
  static Future<bool> sendEmail(String email, {String? subject, String? body}) async {
    String emailUrl = 'mailto:$email';
    if (subject != null || body != null) {
      emailUrl += '?';
      if (subject != null) emailUrl += 'subject=${Uri.encodeComponent(subject)}';
      if (body != null) {
        if (subject != null) emailUrl += '&';
        emailUrl += 'body=${Uri.encodeComponent(body)}';
      }
    }
    
    final uri = Uri.parse(emailUrl);
    return await launchUrl(uri);
  }
  
  /// Abre WhatsApp
  static Future<bool> openWhatsApp(String phoneNumber, {String? message}) async {
    String whatsappUrl = 'https://wa.me/$phoneNumber';
    if (message != null) {
      whatsappUrl += '?text=${Uri.encodeComponent(message)}';
    }
    
    final uri = Uri.parse(whatsappUrl);
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  
  /// Comparte texto
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }
  
  /// Valida si una cadena es un email válido
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  /// Valida si una cadena es un teléfono válido
  static bool isValidPhone(String phone) {
    return RegExp(r'^[+]?[0-9]{9,15}$').hasMatch(phone);
  }
  
  /// Capitaliza la primera letra de cada palabra
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Trunca un texto a una longitud específica
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  /// Genera un ID único simple
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Convierte bytes a formato legible
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Obtiene el saludo según la hora del día
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }
  
  /// Vibración háptica
  static void hapticFeedback({HapticFeedbackType type = HapticFeedbackType.lightImpact}) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }
}

/// Tipos de feedback háptico
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
} 