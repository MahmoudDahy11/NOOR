import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/live_room_entity.dart';

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

  factory LiveRoomModel.fromFirestore(Map<String, dynamic> json, String docId) {
    final creator = Map<String, dynamic>.from(json[AppKeys.roomCreator] ?? {});
    return LiveRoomModel(
      id: docId,
      name: json[AppKeys.roomName] ?? '',
      dhikr: json[AppKeys.roomDhikr] ?? '',
      goal: json[AppKeys.roomGoal] ?? 0,
      type: json[AppKeys.roomType] ?? AppKeys.typeFree,
      creatorId: creator[AppKeys.roomId] ?? '',
      creatorName: creator[AppKeys.roomName] ?? '',
      creatorPhoto: creator[AppKeys.roomPhoto] ?? '',
      status: json[AppKeys.roomStatus] ?? AppKeys.statusPending,
      participantCount: (json[AppKeys.roomParticipants] as List?)?.length ?? 0,
      durationHours:
          (json[AppKeys.roomDurationHours] as num?)?.toDouble() ?? 0.5,
      isPublic: json[AppKeys.roomIsPublic] ?? false,
      expiresAt: _readDate(json[AppKeys.roomExpiresAt]),
      startedAt: _readDate(json[AppKeys.roomStartedAt]),
    );
  }

  static DateTime? _readDate(dynamic value) =>
      value is Timestamp ? value.toDate() : null;
}
