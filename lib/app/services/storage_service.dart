import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Keys
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserToken = 'user_token';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyFirstTime = 'first_time';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLanguage = 'language';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyLastLoginTime = 'last_login_time';
  static const String _keyUserPreferences = 'user_preferences';
  static const String _keyNotifications = 'stored_notifications';

  // User Authentication
  String? get userId => _prefs.getString(_keyUserId);
  set userId(String? value) {
    if (value != null) {
      _prefs.setString(_keyUserId, value);
    } else {
      _prefs.remove(_keyUserId);
    }
  }

  String? get userEmail => _prefs.getString(_keyUserEmail);
  set userEmail(String? value) {
    if (value != null) {
      _prefs.setString(_keyUserEmail, value);
    } else {
      _prefs.remove(_keyUserEmail);
    }
  }

  String? get userToken => _prefs.getString(_keyUserToken);
  set userToken(String? value) {
    if (value != null) {
      _prefs.setString(_keyUserToken, value);
    } else {
      _prefs.remove(_keyUserToken);
    }
  }

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  set isLoggedIn(bool value) => _prefs.setBool(_keyIsLoggedIn, value);

  bool get rememberMe => _prefs.getBool(_keyRememberMe) ?? false;
  set rememberMe(bool value) => _prefs.setBool(_keyRememberMe, value);

  bool get isFirstTime => _prefs.getBool(_keyFirstTime) ?? true;
  set isFirstTime(bool value) => _prefs.setBool(_keyFirstTime, value);

  // App Settings
  bool get notificationsEnabled => _prefs.getBool(_keyNotificationsEnabled) ?? true;
  set notificationsEnabled(bool value) => _prefs.setBool(_keyNotificationsEnabled, value);

  String get language => _prefs.getString(_keyLanguage) ?? 'es';
  set language(String value) => _prefs.setString(_keyLanguage, value);

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'light';
  set themeMode(String value) => _prefs.setString(_keyThemeMode, value);

  String? get fcmToken => _prefs.getString(_keyFcmToken);
  set fcmToken(String? value) {
    if (value != null) {
      _prefs.setString(_keyFcmToken, value);
    } else {
      _prefs.remove(_keyFcmToken);
    }
  }

  DateTime? get lastLoginTime {
    final timestamp = _prefs.getInt(_keyLastLoginTime);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  set lastLoginTime(DateTime? value) {
    if (value != null) {
      _prefs.setInt(_keyLastLoginTime, value.millisecondsSinceEpoch);
    } else {
      _prefs.remove(_keyLastLoginTime);
    }
  }

  // User Preferences
  Map<String, dynamic> get userPreferences {
    final prefsString = _prefs.getString(_keyUserPreferences);
    if (prefsString != null) {
      try {
        return Map<String, dynamic>.from(
          Uri.splitQueryString(prefsString)
        );
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  set userPreferences(Map<String, dynamic> value) {
    final prefsString = value.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    _prefs.setString(_keyUserPreferences, prefsString);
  }

  // Utility Methods
  bool get isLoggedIn => userId != null && userToken != null;

  void saveUserSession({
    required String userId,
    required String email,
    required String token,
    bool rememberMe = false,
  }) {
    this.userId = userId;
    this.userEmail = email;
    this.userToken = token;
    this.rememberMe = rememberMe;
    this.lastLoginTime = DateTime.now();
    this.isLoggedIn = true;
  }

  void clearUserSession() {
    userId = null;
    userEmail = null;
    userToken = null;
    rememberMe = false;
    lastLoginTime = null;
    isLoggedIn = false;
    userPreferences = {};
  }

  void updateUserPreference(String key, dynamic value) {
    final prefs = userPreferences;
    prefs[key] = value;
    userPreferences = prefs;
  }

  T? getUserPreference<T>(String key, [T? defaultValue]) {
    final prefs = userPreferences;
    return prefs[key] as T? ?? defaultValue;
  }

  // Cache Management
  void clearCache() {
    final keysToKeep = [
      _keyUserId,
      _keyUserEmail,
      _keyUserToken,
      _keyIsLoggedIn,
      _keyRememberMe,
      _keyThemeMode,
      _keyLanguage,
      _keyNotificationsEnabled,
      _keyFcmToken,
    ];

    final allKeys = _prefs.getKeys();
    for (final key in allKeys) {
      if (!keysToKeep.contains(key)) {
        _prefs.remove(key);
      }
    }
  }

  void clearAll() {
    _prefs.clear();
  }

  // Debug Methods
  void printAllKeys() {
    print('=== StorageService Debug ===');
    final keys = _prefs.getKeys();
    for (final key in keys) {
      final value = _prefs.get(key);
      print('$key: $value');
    }
    print('===========================');
  }

  Map<String, dynamic> getAllData() {
    final Map<String, dynamic> data = {};
    final keys = _prefs.getKeys();
    for (final key in keys) {
      data[key] = _prefs.get(key);
    }
    return data;
  }

  // Métodos para notificaciones
  void saveNotifications(List<NotificationModel> notifications) {
    final jsonList = notifications.map((n) => n.toJson()).toList();
    _prefs.setString(_keyNotifications, jsonEncode(jsonList));
  }

  List<NotificationModel> getStoredNotifications() {
    final jsonString = _prefs.getString(_keyNotifications);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading stored notifications: $e');
      return [];
    }
  }
} 