import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notification_repo.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  NotificationRepo get _notificationRepo => getIt<NotificationRepo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F14),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifications'),
        centerTitle: false,
      ),
      body: StreamBuilder<List<AppNotificationEntity>>(
        stream: _notificationRepo.watchNotifications(),
        initialData: const [],
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? const [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationCard(
                notification: notification,
                onTap: () async {
                  await _notificationRepo.markAsRead(notification.id);
                  if (context.mounted && notification.roomId != null) {
                    context.pushNamed(
                      AppRouter.liveRoomRoute,
                      pathParameters: {'roomId': notification.roomId!},
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotificationEntity notification;
  final VoidCallback onTap;

  IconData _iconForType() {
    switch (notification.type) {
      case 'room_started':
        return Icons.podcasts_rounded;
      case 'goal_reached':
        return Icons.emoji_events_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF102A1D),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Colors.white10
                  : AppColors.gold.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(),
                  color: notification.isRead ? Colors.white70 : AppColors.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
