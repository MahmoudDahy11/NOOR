import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/create_room_params.dart';
import '../models/room_model.dart';
import '../repositories/room_transaction_helper.dart';

/// CreateRoom Data Source - Firestore and RTDB operations for room creation
class CreateRoomDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseDatabase _rtdb;
  final FirebaseAuth _auth;

  CreateRoomDataSource({
    FirebaseFirestore? firestore,
    FirebaseDatabase? rtdb,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _rtdb = rtdb ?? FirebaseDatabase.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  /// Get user data from Firestore
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final userDoc = await _firestore
          .collection(AppKeys.usersCollection)
          .doc(_uid)
          .get();
      if (!userDoc.exists) {
        throw Exception('User profile not found.');
      }
      return userDoc.data() ?? {};
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Generate a unique room ID
  String generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Save room using transaction
  Future<RoomModel> saveRoom({
    required RoomModel room,
    required CreateRoomParams params,
  }) async {
    try {
      log('[DataSource] Starting room transaction...');
      final helper = RoomTransactionHelper(firestore: _firestore, uid: _uid);
      final txResult = await helper.saveRoomTransaction(room, params);

      if (txResult.isLeft()) {
        txResult.fold(
          (failure) => throw Exception(failure.errMessage),
          (_) => null,
        );
      }

      return room;
    } catch (e) {
      throw Exception('Failed to save room: $e');
    }
  }

  /// Set RTDB counter for live counting.
  /// Initialises `live_counters/{roomId}/total` to 0.
  Future<void> setRtdbCounter(String roomId) async {
    try {
      log('[DataSource] Setting RTDB counter for room: $roomId');
      await _rtdb
          .ref('${AppKeys.liveCountersPath}/$roomId')
          .set({AppKeys.liveCounterTotal: 0})
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      log('[DataSource] RTDB set failed or timed out: $e');
      // Non-blocking — Firestore transaction already completed
    }
  }

  /// Get room by ID
  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final snap = await _firestore
          .collection(AppKeys.roomsCollection)
          .doc(roomId)
          .get();
      if (!snap.exists) return null;
      return RoomModel.fromFirestore(snap.data() ?? {}, snap.id);
    } catch (e) {
      throw Exception('Failed to get room: $e');
    }
  }

  /// Get duration for a room
  Future<double> getRoomDuration(String roomId) async {
    try {
      final snap = await _firestore
          .collection(AppKeys.roomsCollection)
          .doc(roomId)
          .get();
      return (snap.data()?[AppKeys.roomDurationHours] as num).toDouble();
    } catch (e) {
      throw Exception('Failed to get room duration: $e');
    }
  }

  /// Start room transaction
  Future<void> startRoomTransaction(String roomId, double hours) async {
    try {
      log('[DataSource] Starting room transaction for: $roomId');
      final helper = RoomTransactionHelper(firestore: _firestore, uid: _uid);
      final result = await helper.startRoomTransaction(roomId, hours);
      result.fold(
        (failure) => throw Exception(failure.errMessage),
        (_) => null,
      );
    } catch (e) {
      throw Exception('Failed to start room: $e');
    }
  }

  /// Get user's rooms
  Future<List<RoomModel>> getUserRooms() async {
    try {
      final snap = await _firestore
          .collection(AppKeys.roomsCollection)
          .where(AppKeys.roomCreatorId, isEqualTo: _uid)
          .orderBy(AppKeys.roomCreatedAt, descending: true)
          .get();
      return snap.docs
          .map((d) => RoomModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user rooms: $e');
    }
  }
}
