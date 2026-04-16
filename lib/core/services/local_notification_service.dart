import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_keys.dart';
import '../router/app_router.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _roomStartedChannel =
      AndroidNotificationChannel(
        'room_started_channel',
        'Room Started Alerts',
        description: 'Heads-up alerts for live room start notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(_roomStartedChannel);
  }

  static Future<void> showHeadsUpNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'room_started_channel',
        'Room Started Alerts',
        channelDescription:
            'Heads-up alerts for live room start notifications.',
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Tally Islamic',
        color: Color(0xFF2E8B57),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(id, title, body, notificationDetails, payload: payload);
  }

  static Future<void> handleLaunchDetails() async {
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final response = launchDetails?.notificationResponse;
    if (response != null) {
      await _handleNotificationTap(response.payload);
    }
  }

  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response,
  ) {
    _handleNotificationTap(response.payload);
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    _handleNotificationTap(response.payload);
  }

  static Future<void> _handleNotificationTap(String? payload) async {
    if (payload == null || payload.isEmpty) return;

    final roomId = payload.startsWith('{')
        ? _extractRoomIdFromPayload(payload)
        : payload;

    if (roomId == null || roomId.isEmpty) return;

    AppRouter.router.pushNamed(
      AppRouter.liveRoomRoute,
      pathParameters: {AppKeys.roomId: roomId},
    );
  }

  static String? _extractRoomIdFromPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded[AppKeys.roomId]?.toString();
      }
    } catch (_) {}
    return null;
  }
}
