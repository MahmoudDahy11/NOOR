import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/create_room_params.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/create_room_repo.dart';
import '../models/room_model.dart';
import 'room_transaction_helper.dart';

class CreateRoomRepoImpl implements CreateRoomRepo {
  final FirebaseFirestore _firestore;
  final FirebaseDatabase _rtdb;
  final FirebaseAuth _auth;

  CreateRoomRepoImpl({
    FirebaseFirestore? firestore,
    FirebaseDatabase? rtdb,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _rtdb = rtdb ?? FirebaseDatabase.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Future<Either<CustomFailure, RoomEntity>> createRoom(
    CreateRoomParams params,
  ) async {
    try {
      final userDoc = await _firestore.collection('users').doc(_uid).get();
      final userData = userDoc.data()!;

      if (params.isPaid) {
        final balance = (userData['ticket_balance'] ?? 0) as int;
        if (balance < params.ticketsRequired) {
          return left(
            CustomFailure(errMessage: 'Not enough tickets. Visit the store.'),
          );
        }
      }

      final roomId = _generateRoomId();
      final creator = RoomCreatorModel(
        id: _uid,
        name: userData['displayName'] ?? '',
        photo: userData['avatarAsset'] ?? '',
      );

      final room = RoomModel(
        id: roomId,
        name: params.name,
        type: params.type,
        dhikr: params.dhikr,
        goal: params.goal,
        currentProgress: 0,
        creator: creator,
        createdAt: DateTime.now(),
        status: 'pending',
        isPublic: params.isPublic,
        participants: [_uid],
        durationHours: params.durationHours,
      );

      final helper = RoomTransactionHelper(firestore: _firestore, uid: _uid);
      final txResult = await helper.saveRoomTransaction(room, params);

      return txResult.fold((f) => left(f), (_) async {
        await _rtdb.ref('rooms/$roomId').set({'currentCount': 0});
        return right(room);
      });
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> startRoom(String roomId) async {
    try {
      final snap = await _firestore.collection('rooms').doc(roomId).get();
      final hours = (snap.data()?['durationHours'] as num).toDouble();
      final helper = RoomTransactionHelper(firestore: _firestore, uid: _uid);
      return helper.startRoomTransaction(roomId, hours);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, List<RoomEntity>>> getMyRooms() async {
    try {
      final snap = await _firestore
          .collection('rooms')
          .where('creator.id', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .get();
      return right(
        snap.docs.map((d) => RoomModel.fromFirestore(d.data(), d.id)).toList(),
      );
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
