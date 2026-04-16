import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/room_entity.dart';

class RoomCreatorModel extends RoomCreatorEntity {
  const RoomCreatorModel({
    required super.id,
    required super.name,
    required super.photo,
  });

  factory RoomCreatorModel.fromMap(Map<String, dynamic> map) =>
      RoomCreatorModel(
        id: map[AppKeys.roomId] ?? '',
        name: map[AppKeys.roomName] ?? '',
        photo: map[AppKeys.roomPhoto] ?? '',
      );

  Map<String, dynamic> toMap() => {
        AppKeys.roomId: id,
        AppKeys.roomName: name,
        AppKeys.roomPhoto: photo,
      };
}

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.name,
    required super.type,
    required super.dhikr,
    required super.goal,
    required super.currentProgress,
    required super.creator,
    required super.createdAt,
    required super.status,
    required super.isPublic,
    required super.participants,
    required super.durationHours,
    super.expiresAt,
    super.startedAt,
  });

    factory RoomModel.fromFirestore(Map<String, dynamic> json, String docId) =>
      RoomModel(
        id: docId,
        name: json[AppKeys.roomName] ?? '',
        type: json[AppKeys.roomType] ?? AppKeys.typeFree,
        dhikr: json[AppKeys.roomDhikr] ?? '',
        goal: json[AppKeys.roomGoal] ?? 0,
        currentProgress: json[AppKeys.roomCurrentProgress] ?? 0,
        creator: RoomCreatorModel.fromMap(
            json[AppKeys.roomCreator] as Map<String, dynamic>? ?? {}),
        createdAt: (json[AppKeys.roomCreatedAt] as Timestamp).toDate(),
        expiresAt: json[AppKeys.roomExpiresAt] != null
            ? (json[AppKeys.roomExpiresAt] as Timestamp).toDate()
            : null,
        startedAt: json[AppKeys.roomStartedAt] != null
            ? (json[AppKeys.roomStartedAt] as Timestamp).toDate()
            : null,
        status: json[AppKeys.roomStatus] ?? AppKeys.statusPending,
        isPublic: json[AppKeys.roomIsPublic] ?? false,
        participants: List<String>.from(json[AppKeys.roomParticipants] ?? []),
        durationHours: (json[AppKeys.roomDurationHours] as num).toDouble(),
      );

  Map<String, dynamic> toFirestore() => {
        AppKeys.roomName: name,
        AppKeys.roomType: type,
        AppKeys.roomDhikr: dhikr,
        AppKeys.roomGoal: goal,
        AppKeys.roomCurrentProgress: currentProgress,
        AppKeys.roomCreator: (creator as RoomCreatorModel).toMap(),
        AppKeys.roomCreatedAt: Timestamp.fromDate(createdAt),
        AppKeys.roomExpiresAt: expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        AppKeys.roomStartedAt:
            startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        AppKeys.roomStatus: status,
        AppKeys.roomIsPublic: isPublic,
        AppKeys.roomParticipants: participants,
        AppKeys.roomDurationHours: durationHours,
      };
}
