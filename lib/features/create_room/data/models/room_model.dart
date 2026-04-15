import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/room_entity.dart';

class RoomCreatorModel extends RoomCreatorEntity {
  const RoomCreatorModel({
    required super.id,
    required super.name,
    required super.photo,
  });

  factory RoomCreatorModel.fromMap(Map<String, dynamic> map) =>
      RoomCreatorModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        photo: map['photo'] ?? '',
      );

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'photo': photo};
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
        name: json['name'] ?? '',
        type: json['type'] ?? 'free',
        dhikr: json['dhikr'] ?? '',
        goal: json['goal'] ?? 0,
        currentProgress: json['currentProgress'] ?? 0,
        creator: RoomCreatorModel.fromMap(
            json['creator'] as Map<String, dynamic>? ?? {}),
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        expiresAt: json['expiresAt'] != null
            ? (json['expiresAt'] as Timestamp).toDate()
            : null,
        startedAt: json['startedAt'] != null
            ? (json['startedAt'] as Timestamp).toDate()
            : null,
        status: json['status'] ?? 'pending',
        isPublic: json['isPublic'] ?? false,
        participants: List<String>.from(json['participants'] ?? []),
        durationHours: (json['durationHours'] as num).toDouble(),
      );

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'type': type,
        'dhikr': dhikr,
        'goal': goal,
        'currentProgress': currentProgress,
        'creator': (creator as RoomCreatorModel).toMap(),
        'createdAt': Timestamp.fromDate(createdAt),
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        'startedAt':
            startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'status': status,
        'isPublic': isPublic,
        'participants': participants,
        'durationHours': durationHours,
      };
}
