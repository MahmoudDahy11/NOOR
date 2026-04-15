enum RoomType { free, paid }

class RoomCreatorEntity {
  final String id;
  final String name;
  final String photo;

  const RoomCreatorEntity({
    required this.id,
    required this.name,
    required this.photo,
  });
}

class RoomEntity {
  final String id;
  final String name;
  final String type; // 'free' | 'paid'
  final String dhikr;
  final int goal;
  final int currentProgress;
  final RoomCreatorEntity creator;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? startedAt;
  final String status; // 'pending' | 'active' | 'completed' | 'expired'
  final bool isPublic;
  final List<String> participants;
  final double durationHours; // 0.5 for free (30min), 1-24 for paid

  const RoomEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.dhikr,
    required this.goal,
    required this.currentProgress,
    required this.creator,
    required this.createdAt,
    required this.status,
    required this.isPublic,
    required this.participants,
    required this.durationHours,
    this.expiresAt,
    this.startedAt,
  });

  bool get isFree => type == 'free';
  bool get isPaid => type == 'paid';
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
}
