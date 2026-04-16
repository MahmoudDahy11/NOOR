import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/feed_room_entity.dart';
import '../../domain/repositories/feed_repo.dart';
import '../models/feed_room_model.dart';

class FeedRepoImpl implements FeedRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeedRepoImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  static const _pageSize = 10;

  @override
  Future<Either<CustomFailure, List<FeedRoomEntity>>> getRooms({
    required String status,
    FeedRoomEntity? lastRoom,
  }) async {
    try {
      var query = _firestore
          .collection('rooms')
          .where('isPublic', isEqualTo: true)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (lastRoom != null) {
        query = query.startAfter([Timestamp.fromDate(lastRoom.createdAt)]);
      }

      final snap = await query.get();
      final rooms = snap.docs
          .map((d) => FeedRoomModel.fromFirestore(d.data(), d.id))
          .toList();
      return right(rooms);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> joinRoom(String roomId) async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.runTransaction((tx) async {
        final roomRef = _firestore.collection('rooms').doc(roomId);
        final snap = await tx.get(roomRef);
        if (!snap.exists) throw Exception('Room not found.');
        final status = snap.data()?['status'] as String?;
        if (status != 'active') {
          throw Exception('Room is not active yet.');
        }
        final participants = List<String>.from(
          snap.data()?['participants'] ?? [],
        );
        if (!participants.contains(uid)) {
          tx.update(roomRef, {
            'participants': FieldValue.arrayUnion([uid]),
          });
        }
      });
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, FeedRoomEntity>> getRoomById(
    String roomId,
  ) async {
    try {
      final snap = await _firestore
          .collection('rooms')
          .doc(roomId.toUpperCase())
          .get();
      if (!snap.exists) {
        return left(CustomFailure(errMessage: 'Room not found.'));
      }
      final room = FeedRoomModel.fromFirestore(snap.data()!, snap.id);
      return right(room);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
