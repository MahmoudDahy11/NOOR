import '../entities/app_notification_entity.dart';

abstract class NotificationRepo {
  Stream<int> watchUnreadCount();

  Stream<List<AppNotificationEntity>> watchNotifications();

  Future<void> markAsRead(String notificationId);
}
