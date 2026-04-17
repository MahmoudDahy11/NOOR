import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_keys.dart';
import '../router/app_router.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Updated channel ID to v2 to allow sound/importance changes on Android
  static const String channelId = 'room_started_v2';
  static const String _channelName = 'Room Started Alerts';
  static const String _channelDescription =
      'Heads-up alerts for live room start notifications.';
  static const String _notificationIcon = 'ic_launcher_notif';

  static const AndroidNotificationChannel _roomStartedChannel =
      AndroidNotificationChannel(
        channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(_notificationIcon);
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

  static String? buildRoomPayload(String? roomId) {
    if (roomId == null || roomId.isEmpty) {
      return null;
    }

    return jsonEncode({
      AppKeys.notificationRoute: AppRouter.liveRoomRoute,
      AppKeys.notificationRoomId: roomId,
    });
  }

  static String? extractRoomIdFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final roomId =
            decoded[AppKeys.notificationRoomId]?.toString() ??
            decoded[AppKeys.roomId]?.toString();
        if (roomId != null && roomId.isNotEmpty) {
          return roomId;
        }
      }
    } catch (_) {
      if (!payload.startsWith('{')) {
        return payload;
      }
    }

    return null;
  }

  static Future<void> showHeadsUpNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final safePayload = extractRoomIdFromPayload(payload) == null
        ? payload
        : buildRoomPayload(extractRoomIdFromPayload(payload));

    try {
      await _plugin.show(
        id,
        title,
        body,
        _buildNotificationDetails(_notificationIcon),
        payload: safePayload,
      );
    } catch (_) {
      await _plugin.show(
        id,
        title,
        body,
        _buildNotificationDetails(_notificationIcon),
        payload: safePayload,
      );
    }
  }

  static Future<bool> handleLaunchDetails() async {
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final response = launchDetails?.notificationResponse;
    if (response != null) {
      await _handleNotificationTap(response.payload);
      return true;
    }

    return false;
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

  static Future<void> navigateToRoom(String roomId) async {
    if (roomId.isEmpty) return;

    AppRouter.router.pushNamed(
      AppRouter.liveRoomRoute,
      pathParameters: {AppKeys.roomId: roomId},
    );
  }

  static Future<void> _handleNotificationTap(String? payload) async {
    final roomId = extractRoomIdFromPayload(payload);
    if (roomId == null || roomId.isEmpty) return;

    await navigateToRoom(roomId);
  }

  static NotificationDetails _buildNotificationDetails(String androidIcon) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelName,
        channelDescription: _channelDescription,
        icon: androidIcon,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Tally Islamic',
        color: const Color(0xFF2E8B57),
        enableVibration: true,
        playSound: true,
        showWhen: true,
        fullScreenIntent: true,
        ongoing: false,
        autoCancel: true,
        enableLights: true,
        ledColor: const Color(0xFF2E8B57),
        ledOnMs: 1000,
        ledOffMs: 1000,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
