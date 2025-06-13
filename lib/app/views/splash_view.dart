import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

// Using StatefulWidget instead of GetView to handle navigation directly
class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);
  
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }
  
  Future<void> _navigateAfterDelay() async {
    // Debug logs
    print('SplashView: Waiting 2 seconds before navigation...');
    
    // Wait to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    // Debug logs
    print('SplashView: Navigating to Routes.LOGIN');
    
    // Navigate to login screen
    if (mounted) {
      try {
        Get.offAllNamed(Routes.LOGIN);
      } catch (e) {
        print('SplashView: Error during navigation: $e');
        // Try alternative navigation
        try {
          Get.offNamed(Routes.LOGIN);
        } catch (e) {
          print('SplashView: Critical navigation error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.celebration,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Título
            Text(
              'SorteosMicro',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 80),
            
            // Indicador de carga
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
} 