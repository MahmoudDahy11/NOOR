import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/app_notification_entity.dart';

class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    required super.sentAt,
    super.roomId,
  });

  factory AppNotificationModel.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return AppNotificationModel(
      id: documentId,
      title: json[AppKeys.notificationTitle] as String? ?? 'Noor Islamic',
      body: json[AppKeys.notificationBody] as String? ?? '',
      type: json[AppKeys.notificationType] as String? ?? 'system',
      isRead: json[AppKeys.notificationIsRead] as bool? ?? false,
      sentAt: (json[AppKeys.notificationSentAt] as Timestamp?)?.toDate(),
      roomId: json[AppKeys.notificationRoomId] as String?,
    );
  }
}
