class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://ggoichcdkrqugdqumrda.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdnb2ljaGNka3JxdWdkcXVtcmRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3NzI4NTYsImV4cCI6MjA2NTM0ODg1Nn0.7hYrkvrQ-dY9qh7pmxk8ON9ph7mNblgUemV9vHU0arc';
  
  // Stripe Configuration
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  
  // App Configuration
  static const String appName = 'SorteosMicro';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'soporte@sorteosmicro.com';
  static const String termsUrl = 'https://sorteosmicro.com/terminos';
  static const String privacyUrl = 'https://sorteosmicro.com/privacidad';
  
  // Business Logic
  static const double minDepositAmount = 5.0;
  static const double maxDepositAmount = 500.0;
  static const int maxTicketsPerUser = 50;
  static const int minParticipantsToStart = 10;
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'bizum',
    'transfer',
    'paypal',
  ];
  
  // Raffle Configuration
  static const Map<String, dynamic> raffleConfig = {
    'morning': {
      'hour': 9,
      'minPrize': 75,
      'maxPrize': 100,
      'ticketPrice': 1.5,
    },
    'afternoon': {
      'hour': 14,
      'minPrize': 100,
      'maxPrize': 150,
      'ticketPrice': 2.0,
    },
    'evening': {
      'hour': 20,
      'minPrize': 150,
      'maxPrize': 200,
      'ticketPrice': 2.0,
    },
    'night': {
      'hour': 23,
      'minPrize': 50,
      'maxPrize': 75,
      'ticketPrice': 1.5,
    },
  };
  
  // Notification Topics
  static const String newRafflesTopic = 'new_raffles';
  static const String winnersAnnouncementTopic = 'winners';
  static const String depositsApprovedTopic = 'deposits_approved';
  
  // Social Media
  static const String instagramUrl = 'https://instagram.com/sorteosmicro';
  static const String tiktokUrl = 'https://tiktok.com/@sorteosmicro';
  static const String whatsappNumber = '+34600123456';
  
  // Development flags
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
} 