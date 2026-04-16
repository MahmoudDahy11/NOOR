import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/live_room_entity.dart';

/// Firestore-backed data model for [LiveRoomEntity].
class LiveRoomModel extends LiveRoomEntity {
  const LiveRoomModel({
    required super.id,
    required super.name,
    required super.dhikr,
    required super.goal,
    required super.type,
    required super.creatorId,
    required super.creatorName,
    required super.creatorPhoto,
    required super.status,
    required super.participantCount,
    required super.durationHours,
    required super.isPublic,
    super.expiresAt,
    super.startedAt,
  });

  factory LiveRoomModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    final creatorMap =
        json[AppKeys.roomCreator] as Map<String, dynamic>? ?? {};
    return LiveRoomModel(
      id: docId,
      name: json[AppKeys.roomName] ?? '',
      dhikr: json[AppKeys.roomDhikr] ?? '',
      goal: json[AppKeys.roomGoal] ?? 0,
      type: json[AppKeys.roomType] ?? AppKeys.typeFree,
      creatorId: creatorMap[AppKeys.roomId] ?? '',
      creatorName: creatorMap[AppKeys.roomName] ?? '',
      creatorPhoto: creatorMap[AppKeys.roomPhoto] ?? '',
      status: json[AppKeys.roomStatus] ?? AppKeys.statusPending,
      participantCount:
          (json[AppKeys.roomParticipants] as List?)?.length ?? 0,
      durationHours:
          (json[AppKeys.roomDurationHours] as num?)?.toDouble() ?? 0.5,
      isPublic: json[AppKeys.roomIsPublic] ?? false,
      expiresAt: json[AppKeys.roomExpiresAt] != null
          ? (json[AppKeys.roomExpiresAt] as Timestamp).toDate()
          : null,
      startedAt: json[AppKeys.roomStartedAt] != null
          ? (json[AppKeys.roomStartedAt] as Timestamp).toDate()
          : null,
    );
  }
}
