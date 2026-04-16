/// Immutable snapshot of a live room's metadata (from Firestore).
/// Real-time counts (total / personal) live in RTDB and are tracked
/// separately in the Cubit state.
class LiveRoomEntity {
  final String id;
  final String name;
  final String dhikr;
  final int goal;
  final String type; // 'free' | 'paid'
  final String creatorId;
  final String creatorName;
  final String creatorPhoto;
  final String status; // 'active' | 'completed' | 'expired'
  final DateTime? expiresAt;
  final DateTime? startedAt;
  final int participantCount;
  final double durationHours;
  final bool isPublic;

  const LiveRoomEntity({
    required this.id,
    required this.name,
    required this.dhikr,
    required this.goal,
    required this.type,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhoto,
    required this.status,
    required this.participantCount,
    required this.durationHours,
    required this.isPublic,
    this.expiresAt,
    this.startedAt,
  });

  bool get isFree => type == 'free';
  bool get isPaid => type == 'paid';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
