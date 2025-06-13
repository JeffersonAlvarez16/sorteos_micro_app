import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/config/app_config.dart';
import 'app/themes/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/storage_service.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  // Inicializar servicios
  await initServices();
  
  runApp(SorteosMicroApp());
}

Future<void> initServices() async {
  // Inicializar servicios principales
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => NotificationService().init());
}

class SorteosMicroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SorteosMicro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
      locale: Locale('es', 'ES'),
      fallbackLocale: Locale('es', 'ES'),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
} 