import 'package:get/get.dart';

import '../routes/app_pages.dart';

class SplashController extends GetxController {
  // Temporarily removed AuthService dependency for direct navigation
  // final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Esperar un poco para mostrar el splash
    print('SplashController: Waiting 2 seconds before navigation...');
    await Future.delayed(const Duration(seconds: 2));
    
    // TEMPORARY FIX: Skip authentication check and go directly to LOGIN
    print('SplashController: Bypassing auth check, navigating directly to LOGIN');
    
    try {
      // Use named route navigation which is safer
      print('SplashController: Navigating to Routes.LOGIN');
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('SplashController: Error during navigation: $e');
      // Try an alternative navigation method if the first fails
      try {
        print('SplashController: Attempting alternative navigation');
        Get.offNamed(Routes.LOGIN);
      } catch (e) {
        print('SplashController: Critical navigation error: $e');
      }
    }
  }
} 