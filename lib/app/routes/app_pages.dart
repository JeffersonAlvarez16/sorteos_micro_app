import 'package:get/get.dart';

import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/raffle/bindings/raffle_binding.dart';
import '../modules/raffle/views/raffle_detail_view.dart';
import '../modules/raffle/views/raffle_live_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/deposit/bindings/deposit_binding.dart';
import '../modules/deposit/views/deposit_view.dart';
import '../modules/deposit/views/deposit_request_view.dart';
import '../modules/statistics/bindings/statistics_binding.dart';
import '../modules/statistics/views/statistics_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

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
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Main Navigation
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
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
    GetPage(
      name: _Paths.RAFFLE_LIVE,
      page: () => const RaffleLiveView(),
      binding: RaffleBinding(),
      transition: Transition.zoom,
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
      page: () => const DepositRequestView(),
      binding: DepositBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Statistics
    GetPage(
      name: _Paths.STATISTICS,
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Notifications
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Settings
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
} 