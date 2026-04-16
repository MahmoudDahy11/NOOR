import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/feed_room_entity.dart';

class FeedRoomModel extends FeedRoomEntity {
  const FeedRoomModel({
    required super.id,
    required super.name,
    required super.dhikr,
    required super.goal,
    required super.currentProgress,
    required super.status,
    required super.isPublic,
    required super.creator,
    required super.createdAt,
    required super.participantCount,
    required super.type,
    super.expiresAt,
  });

  factory FeedRoomModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    final creatorMap =
        json['creator'] as Map<String, dynamic>? ?? {};
    return FeedRoomModel(
      id: docId,
      name: json['name'] ?? '',
      dhikr: json['dhikr'] ?? '',
      goal: json['goal'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      status: json['status'] ?? 'pending',
      isPublic: json['isPublic'] ?? false,
      type: json['type'] ?? 'free',
      creator: FeedRoomCreator(
        id: creatorMap['id'] ?? '',
        name: creatorMap['name'] ?? '',
        photo: creatorMap['photo'] ?? '',
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      expiresAt: json['expiresAt'] != null
          ? (json['expiresAt'] as Timestamp).toDate()
          : null,
      participantCount:
          (json['participants'] as List?)?.length ?? 0,
    );
  }
}
