import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/home_controller.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

/// Binding inicial que se ejecuta al iniciar la aplicación
/// Registra los controladores y servicios principales
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Servicios principales (ya inicializados en main.dart)
    Get.lazyPut<StorageService>(() => Get.find<StorageService>());
    Get.lazyPut<AuthService>(() => Get.find<AuthService>());
    Get.lazyPut<NotificationService>(() => Get.find<NotificationService>());
    
    // Controladores principales
    Get.lazyPut<ThemeController>(() => ThemeController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
} 