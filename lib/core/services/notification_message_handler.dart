import 'dart:math' show Random;

import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/app_keys.dart';
import 'local_notification_service.dart';

typedef ShowHeadsUpNotification =
    Future<void> Function({
      required int id,
      required String title,
      required String body,
      String? payload,
    });

typedef NavigateToRoom = Future<void> Function(String roomId);

class NotificationMessageHandler {
  NotificationMessageHandler._();

  static String? extractRoomId(RemoteMessage message) {
    final directRoomId = message.data[AppKeys.notificationRoomId]?.toString();
    if (directRoomId != null && directRoomId.isNotEmpty) {
      return directRoomId;
    }

    final legacyRoomId = message.data[AppKeys.roomId]?.toString();
    if (legacyRoomId != null && legacyRoomId.isNotEmpty) {
      return legacyRoomId;
    }

    return null;
  }

  static String resolveTitle(RemoteMessage message) {
    return message.notification?.title ??
        message.data[AppKeys.notificationTitle] ??
        'Room Started';
  }

  static String resolveBody(RemoteMessage message) {
    return message.notification?.body ??
        message.data[AppKeys.notificationBody] ??
        'A live room is waiting for you.';
  }

  static int resolveNotificationId(RemoteMessage message) {
    return message.messageId?.hashCode ?? Random().nextInt(1 << 20);
  }

  static String? buildPayload(RemoteMessage message) {
    return LocalNotificationService.buildRoomPayload(extractRoomId(message));
  }

  static Future<void> handleForegroundMessage(
    RemoteMessage message, {
    required ShowHeadsUpNotification showNotification,
  }) async {
    await showNotification(
      id: resolveNotificationId(message),
      title: resolveTitle(message),
      body: resolveBody(message),
      payload: buildPayload(message),
    );
  }

  static Future<void> navigateFromMessage(
    RemoteMessage message, {
    required NavigateToRoom navigateToRoom,
  }) async {
    final roomId = extractRoomId(message);
    if (roomId == null || roomId.isEmpty) {
      return;
    }

    await navigateToRoom(roomId);
  }
}
