part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const RAFFLE_DETAIL = _Paths.RAFFLE_DETAIL;
  static const RAFFLE_LIVE = _Paths.RAFFLE_LIVE;
  static const PROFILE = _Paths.PROFILE;
  static const DEPOSIT = _Paths.DEPOSIT;
  static const DEPOSIT_REQUEST = _Paths.DEPOSIT_REQUEST;
  static const STATISTICS = _Paths.STATISTICS;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const SETTINGS = _Paths.SETTINGS;
  static const PAYMENT_METHODS = _Paths.PAYMENT_METHODS;
}

abstract class _Paths {
  _Paths._();
  
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const RAFFLE_DETAIL = '/raffle-detail';
  static const RAFFLE_LIVE = '/raffle-live';
  static const PROFILE = '/profile';
  static const DEPOSIT = '/deposit';
  static const DEPOSIT_REQUEST = '/deposit-request';
  static const STATISTICS = '/statistics';
  static const NOTIFICATIONS = '/notifications';
  static const SETTINGS = '/settings';
  static const PAYMENT_METHODS = '/payment-methods';
} 