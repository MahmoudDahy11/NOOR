import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/auth/data/service/local_storage.dart';
import '../constants/app_keys.dart';
import 'notification_message_handler.dart';

class RemoteNotificationStoreService {
  RemoteNotificationStoreService._();

  static Future<void> storeIncomingMessageForCurrentUser(
    RemoteMessage message, {
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) async {
    final authUid = (auth ?? FirebaseAuth.instance).currentUser?.uid;
    final cachedUid = LocalStorageService.getUserId();
    final uid = authUid ?? cachedUid;

    if (uid == null || uid.isEmpty) return;

    final notificationId =
        message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final data = Map<String, dynamic>.from(message.data);
    final roomId = NotificationMessageHandler.extractRoomId(message);

    await (firestore ?? FirebaseFirestore.instance)
        .collection(AppKeys.usersCollection)
        .doc(uid)
        .collection(AppKeys.notificationsCollection)
        .doc(notificationId)
        .set({
          AppKeys.notificationId: notificationId,
          AppKeys.notificationTitle:
              message.notification?.title ??
              data[AppKeys.notificationTitle] ??
              'Noor Islamic',
          AppKeys.notificationBody:
              message.notification?.body ??
              data[AppKeys.notificationBody] ??
              '',
          AppKeys.notificationType:
              data[AppKeys.notificationType] ??
              (roomId != null ? AppKeys.notificationTypeRoomStarted : 'system'),
          AppKeys.notificationRoomId: roomId,
          AppKeys.notificationRoute: data[AppKeys.notificationRoute],
          AppKeys.notificationData: data,
          AppKeys.notificationIsRead: false,
          AppKeys.notificationSentAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
