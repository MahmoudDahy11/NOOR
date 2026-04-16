import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
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
        json[AppKeys.roomCreator] as Map<String, dynamic>? ?? {};
    return FeedRoomModel(
      id: docId,
      name: json[AppKeys.roomName] ?? '',
      dhikr: json[AppKeys.roomDhikr] ?? '',
      goal: json[AppKeys.roomGoal] ?? 0,
      currentProgress: json[AppKeys.roomCurrentProgress] ?? 0,
      status: json[AppKeys.roomStatus] ?? AppKeys.statusPending,
      isPublic: json[AppKeys.roomIsPublic] ?? false,
      type: json[AppKeys.roomType] ?? AppKeys.typeFree,
      creator: FeedRoomCreator(
        id: creatorMap[AppKeys.roomId] ?? '',
        name: creatorMap[AppKeys.roomName] ?? '',
        photo: creatorMap[AppKeys.roomPhoto] ?? '',
      ),
      createdAt: (json[AppKeys.roomCreatedAt] as Timestamp).toDate(),
      expiresAt: json[AppKeys.roomExpiresAt] != null
          ? (json[AppKeys.roomExpiresAt] as Timestamp).toDate()
          : null,
      participantCount:
          (json[AppKeys.roomParticipants] as List?)?.length ?? 0,
    );
  }
}
