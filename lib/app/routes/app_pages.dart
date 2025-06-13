import 'package:get/get.dart';

import '../bindings/splash_binding.dart';
import '../views/splash_view.dart';
import '../bindings/auth_binding.dart';
import '../views/auth_view.dart';
import '../bindings/home_binding.dart';
import '../views/home_view.dart';
import '../bindings/raffle_binding.dart';
import '../views/raffle_detail_view.dart';
import '../bindings/profile_binding.dart';
import '../views/profile_view.dart';
import '../bindings/deposit_binding.dart';
import '../views/deposit_view.dart';
import '../views/deposit_form_view.dart' as new_deposit;
import '../bindings/payment_methods_binding.dart';
import '../views/payment_methods_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // Splash
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    
    // Authentication
    GetPage(
      name: _Paths.LOGIN,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Main Navigation
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    
    // Raffle
    GetPage(
      name: _Paths.RAFFLE_DETAIL,
      page: () => const RaffleDetailView(),
      binding: RaffleBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Profile
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Deposits
    GetPage(
      name: _Paths.DEPOSIT,
      page: () => const DepositView(),
      binding: DepositBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.DEPOSIT_REQUEST,
      page: () => const new_deposit.NewDepositView(),
      binding: DepositBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Payment Methods
    GetPage(
      name: _Paths.PAYMENT_METHODS,
      page: () => const PaymentMethodsView(),
      binding: PaymentMethodsBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
} 