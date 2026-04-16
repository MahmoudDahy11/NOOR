import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/constants/app_keys.dart';

class LiveRoomDataSource {
  LiveRoomDataSource({
    FirebaseDatabase? rtdb,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _rtdb = rtdb ?? FirebaseDatabase.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseDatabase _rtdb;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Timer? _firestoreUpdateTimer;
  int _pendingIncrements = 0;

  String get uid => _auth.currentUser!.uid;

  Stream<int> watchTotalCounter(String roomId) => _counterRef(
    roomId,
    AppKeys.liveCounterTotal,
  ).onValue.map((event) => (event.snapshot.value as int?) ?? 0);

  Stream<int> watchPersonalCounter(String roomId) => _counterRef(
    roomId,
    '${AppKeys.liveCounterParticipants}/$uid',
  ).onValue.map((event) => (event.snapshot.value as int?) ?? 0);

  Future<void> incrementCounters(String roomId) async {
    final userId = uid;
    final basePath = '${AppKeys.liveCountersPath}/$roomId';
    await _rtdb.ref().update({
      '$basePath/${AppKeys.liveCounterTotal}': ServerValue.increment(1),
      '$basePath/${AppKeys.liveCounterParticipants}/$userId':
          ServerValue.increment(1),
    });

    _pendingIncrements++;
    if (_firestoreUpdateTimer?.isActive ?? false) {
      _firestoreUpdateTimer!.cancel();
    }
    _firestoreUpdateTimer = Timer(const Duration(seconds: 2), () {
      if (_pendingIncrements == 0) return;
      final countToUpdate = _pendingIncrements;
      _pendingIncrements = 0;
      _firestore.collection(AppKeys.usersCollection).doc(userId).update({
        AppKeys.userStatsTotalCounts: FieldValue.increment(countToUpdate),
      });
    });
  }

  Future<void> resetCounters(String roomId) async {
    await _rtdb.ref('${AppKeys.liveCountersPath}/$roomId').set({
      AppKeys.liveCounterTotal: 0,
    });
  }

  Future<Map<String, dynamic>> getRoomData(String roomId) async {
    final roomRef = _firestore.collection(AppKeys.roomsCollection).doc(roomId);
    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(roomRef);
      final data = snap.data();
      if (!snap.exists || data == null) throw Exception('Room not found.');
      _ensureRoomIsJoinable(data);
      final participants = List<String>.from(
        data[AppKeys.roomParticipants] ?? [],
      );
      if (!participants.contains(uid)) {
        tx.update(roomRef, {
          AppKeys.roomParticipants: FieldValue.arrayUnion([uid]),
        });
      }
      return data;
    });
  }

  Future<void> removeParticipant(String roomId) async {
    await _firestore.collection(AppKeys.roomsCollection).doc(roomId).update({
      AppKeys.roomParticipants: FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> completeRoom(String roomId) async {
    final snapshot = await _rtdb
        .ref('${AppKeys.liveCountersPath}/$roomId/${AppKeys.liveCounterTotal}')
        .get();
    final finalCount = (snapshot.value as int?) ?? 0;

    await _firestore.collection(AppKeys.roomsCollection).doc(roomId).update({
      AppKeys.roomStatus: AppKeys.statusCompleted,
      AppKeys.roomCurrentProgress: finalCount,
    });
    await _rtdb.ref('${AppKeys.liveCountersPath}/$roomId').remove();
  }

  bool isCreator(String creatorId) => uid == creatorId;

  DatabaseReference _counterRef(String roomId, String leaf) =>
      _rtdb.ref('${AppKeys.liveCountersPath}/$roomId/$leaf');

  void _ensureRoomIsJoinable(Map<String, dynamic> data) {
    final status = data[AppKeys.roomStatus] as String? ?? AppKeys.statusPending;
    final expiresAt = (data[AppKeys.roomExpiresAt] as Timestamp?)?.toDate();
    if (status != AppKeys.statusActive) throw Exception('Room is not active.');
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      throw Exception('Room has expired.');
    }
  }
}
