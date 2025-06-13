/// Constantes generales de la aplicación
class AppConstants {
  // Rutas de assets
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';
  static const String soundsPath = 'assets/sounds/';
  
  // Imágenes por defecto
  static const String defaultAvatar = '${imagesPath}default_avatar.png';
  static const String logoImage = '${imagesPath}logo.png';
  static const String emptyStateImage = '${imagesPath}empty_state.png';
  
  // Animaciones
  static const String loadingAnimation = '${animationsPath}loading.json';
  static const String successAnimation = '${animationsPath}success.json';
  static const String errorAnimation = '${animationsPath}error.json';
  static const String emptyAnimation = '${animationsPath}empty.json';
  
  // Duraciones de animación
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);
  
  // Límites
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  
  // Formatos permitidos
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Regex patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[+]?[0-9]{9,15}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  
  // Mensajes de error comunes
  static const String networkError = 'Error de conexión. Verifica tu internet.';
  static const String serverError = 'Error del servidor. Inténtalo más tarde.';
  static const String unknownError = 'Ha ocurrido un error inesperado.';
  static const String sessionExpired = 'Tu sesión ha expirado. Inicia sesión nuevamente.';
  
  // Claves de almacenamiento local
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications_enabled';
  static const String biometricKey = 'biometric_enabled';
  
  // Estados de sorteos
  static const String raffleStatusActive = 'active';
  static const String raffleStatusCompleted = 'completed';
  static const String raffleStatusCancelled = 'cancelled';
  static const String raffleStatusPending = 'pending';
  
  // Estados de depósitos
  static const String depositStatusPending = 'pending';
  static const String depositStatusApproved = 'approved';
  static const String depositStatusRejected = 'rejected';
  static const String depositStatusProcessing = 'processing';
  
  // Tipos de notificación
  static const String notificationTypeRaffle = 'raffle';
  static const String notificationTypeDeposit = 'deposit';
  static const String notificationTypeWinner = 'winner';
  static const String notificationTypeGeneral = 'general';
  
  // URLs útiles
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.sorteosmicro.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/sorteosmicro/id123456789';
  
  // Configuración de paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
} 