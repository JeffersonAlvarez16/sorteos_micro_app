import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../config/app_config.dart';
import 'storage_service.dart';

// Handler para notificaciones en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  await NotificationService.to.showNotification(
    title: message.notification?.title ?? 'Nueva notificación',
    body: message.notification?.body ?? '',
    payload: jsonEncode(message.data),
  );
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StorageService _storage = StorageService.to;

  final RxBool _isInitialized = false.obs;
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;

  // Getters
  bool get isInitialized => _isInitialized.value;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<NotificationService> init() async {
    await _initializeLocalNotifications();
    try {
      await _initializeFirebaseMessaging();
    } catch (e) {
      print('Error initializing Firebase Messaging, continuing without it: $e');
      // Continue without Firebase Messaging
    }
    await _loadStoredNotifications();

    _isInitialized.value = true;
    return this;
  }

  // Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificaciones para Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  // Crear canales de notificación
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'raffles',
        'Sorteos',
        description: 'Notificaciones sobre sorteos activos y resultados',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
      AndroidNotificationChannel(
        'deposits',
        'Depósitos',
        description: 'Notificaciones sobre depósitos y transacciones',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        'general',
        'General',
        description: 'Notificaciones generales de la aplicación',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // Inicializar Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Solicitar permisos
      await _requestPermissions();

      // SKIP token retrieval for now - this is causing the error
      // We'll continue with the rest of the initialization
      print('Skipping FCM token retrieval due to known issues');

      // Set up safe message handlers with try-catch blocks
      try {
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage,
            onError: (error) => print('Error in onMessage handler: $error'));
      } catch (e) {
        print('Failed to set up onMessage handler: $e');
      }

      try {
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp,
            onError: (error) =>
                print('Error in onMessageOpenedApp handler: $error'));
      } catch (e) {
        print('Failed to set up onMessageOpenedApp handler: $e');
      }

      // Skip background handler registration as it might also be problematic
      print('Skipping background message handler registration');

      // Skip initial message check as it might also cause errors
      print('Skipping initial message check');
    } catch (e) {
      print('Error in Firebase Messaging initialization: $e');
      // Allow the app to continue without Firebase Messaging
    }
  }

  // Solicitar permisos
  Future<void> _requestPermissions() async {
    // Permisos de Firebase
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Permission granted: ${settings.authorizationStatus}');

    // Permisos adicionales para Android
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  // Manejar mensajes en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      showNotification(
        title: message.notification!.title ?? 'Nueva notificación',
        body: message.notification!.body ?? '',
        payload: jsonEncode(message.data),
      );
    }

    _addNotificationToList(message);
  }

  // Manejar cuando se abre la app desde una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    _handleNotificationAction(message.data);
  }

  // Manejar tap en notificación local
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationAction(data);
    }
  }

  // Manejar acciones de notificación
  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    switch (type) {
      case 'raffle_started':
        if (id != null) {
          Get.toNamed('/raffle-detail', arguments: {'raffleId': id});
        }
        break;
      case 'raffle_result':
        if (id != null) {
          Get.toNamed('/raffle-detail', arguments: {'raffleId': id});
        }
        break;
      case 'deposit_approved':
      case 'deposit_rejected':
        Get.toNamed('/deposits');
        break;
      case 'balance_updated':
        Get.toNamed('/profile');
        break;
      default:
        Get.toNamed('/home');
    }
  }

  // Mostrar notificación local
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'general',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Programar notificación
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'general',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents:
          null, // o usa `DateTimeComponents.time` si deseas que se repita
    );
  }

  // Suscribirse a tópicos
  Future<void> subscribeToTopics() async {
    for (final topic in AppConfig.notificationTopics) {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    }
  }

  // Desuscribirse de tópicos
  Future<void> unsubscribeFromTopics() async {
    for (final topic in AppConfig.notificationTopics) {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    }
  }

  // Agregar notificación a la lista
  void _addNotificationToList(RemoteMessage message) {
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Nueva notificación',
      body: message.notification?.body ?? '',
      data: message.data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification);
    _saveNotifications();
  }

  // Marcar notificación como leída
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveNotifications();
    }
  }

  // Marcar todas como leídas
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _saveNotifications();
  }

  // Eliminar notificación
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _saveNotifications();
  }

  // Limpiar todas las notificaciones
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _localNotifications.cancelAll();
    _saveNotifications();
  }

  // Cargar notificaciones guardadas
  Future<void> _loadStoredNotifications() async {
    final stored = _storage.getStoredNotifications();
    _notifications.assignAll(stored);
  }

  // Guardar notificaciones
  void _saveNotifications() {
    _storage.saveNotifications(_notifications);
  }

  // Obtener nombre del canal
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'raffles':
        return 'Sorteos';
      case 'deposits':
        return 'Depósitos';
      case 'general':
      default:
        return 'General';
    }
  }

  // Obtener descripción del canal
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'raffles':
        return 'Notificaciones sobre sorteos activos y resultados';
      case 'deposits':
        return 'Notificaciones sobre depósitos y transacciones';
      case 'general':
      default:
        return 'Notificaciones generales de la aplicación';
    }
  }
}

// Modelo de notificación
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.timestamp,
    required this.isRead,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
    );
  }
}
