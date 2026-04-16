class FeedRoomCreator {
  final String id;
  final String name;
  final String photo;

  const FeedRoomCreator({
    required this.id,
    required this.name,
    required this.photo,
  });
}

class FeedRoomEntity {
  final String id;
  final String name;
  final String dhikr;
  final int goal;
  final int currentProgress;
  final String status; // 'active' | 'pending'
  final bool isPublic;
  final FeedRoomCreator creator;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int participantCount;
  final String type; // 'free' | 'paid'

  const FeedRoomEntity({
    required this.id,
    required this.name,
    required this.dhikr,
    required this.goal,
    required this.currentProgress,
    required this.status,
    required this.isPublic,
    required this.creator,
    required this.createdAt,
    required this.participantCount,
    required this.type,
    this.expiresAt,
  });

  double get progressPercent =>
      goal == 0 ? 0 : (currentProgress / goal).clamp(0.0, 1.0);

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
