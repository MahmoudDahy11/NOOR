import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/create_room_params.dart';
import '../models/room_model.dart';

class RoomTransactionHelper {
  final FirebaseFirestore firestore;
  final String uid;

  const RoomTransactionHelper({required this.firestore, required this.uid});
  Future<Either<CustomFailure, void>> saveRoomTransaction(
    RoomModel room,
    CreateRoomParams params,
  ) async {
    try {
      await firestore.runTransaction((tx) async {
        final roomRef = firestore.collection('rooms').doc(room.id);
        final userRef = firestore.collection('users').doc(uid);

        // 1. ALL READS FIRST
        final userSnap = await tx.get(userRef);

        if (params.isPaid) {
          final balance = (userSnap.data()?['ticket_balance'] ?? 0) as int;
          if (balance < params.ticketsRequired) {
            throw Exception('Not enough tickets.');
          }
          // 2. ALL WRITES LAST
          tx.update(userRef, {
            'ticket_balance': balance - params.ticketsRequired,
          });
        }

        tx.set(roomRef, room.toFirestore());
      });
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  Future<Either<CustomFailure, void>> startRoomTransaction(
    String roomId,
    double durationHours,
  ) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(
        Duration(minutes: (durationHours * 60).round()),
      );
      await firestore.collection('rooms').doc(roomId).update({
        'status': 'active',
        'startedAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
