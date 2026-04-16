import 'package:equatable/equatable.dart';

class AppNotificationEntity extends Equatable {
  const AppNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.sentAt,
    this.roomId,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? sentAt;
  final String? roomId;

  @override
  List<Object?> get props => [id, title, body, type, isRead, sentAt, roomId];
}
