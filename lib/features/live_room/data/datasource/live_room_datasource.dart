import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/constants/app_keys.dart';

/// Low-level data source for the Live Room feature.
///
/// RTDB paths:
///   `live_counters/{roomId}/total`           → global room count
///   `live_counters/{roomId}/participants/{uid}` → per-user count
///
/// Firestore collection: `rooms/{roomId}` (metadata only).
class LiveRoomDataSource {
  final FirebaseDatabase _rtdb;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LiveRoomDataSource({
    FirebaseDatabase? rtdb,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _rtdb = rtdb ?? FirebaseDatabase.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  // ---------------------------------------------------------------------------
  // RTDB — Real-time counters
  // ---------------------------------------------------------------------------

  /// Streams the global counter from RTDB.
  Stream<int> watchTotalCounter(String roomId) {
    return _rtdb
        .ref('${AppKeys.liveCountersPath}/$roomId/${AppKeys.liveCounterTotal}')
        .onValue
        .map((event) => (event.snapshot.value as int?) ?? 0);
  }

  /// Streams the current user's personal counter from RTDB.
  Stream<int> watchPersonalCounter(String roomId) {
    return _rtdb
        .ref(
          '${AppKeys.liveCountersPath}/$roomId/'
          '${AppKeys.liveCounterParticipants}/$uid',
        )
        .onValue
        .map((event) => (event.snapshot.value as int?) ?? 0);
  }

  /// Atomically increments **both** [total] and [participants/{uid}]
  /// using a single multi-path RTDB update with `ServerValue.increment`.
  Future<void> incrementCounters(String roomId) async {
    final basePath = '${AppKeys.liveCountersPath}/$roomId';
    final updates = <String, dynamic>{
      '$basePath/${AppKeys.liveCounterTotal}': ServerValue.increment(1),
      '$basePath/${AppKeys.liveCounterParticipants}/$uid':
          ServerValue.increment(1),
    };
    await _rtdb.ref().update(updates);
  }

  /// Resets counters — removes all participant data and sets total to 0.
  Future<void> resetCounters(String roomId) async {
    log('[LiveRoomDS] Resetting counters for room: $roomId');
    await _rtdb
        .ref('${AppKeys.liveCountersPath}/$roomId')
        .set({AppKeys.liveCounterTotal: 0});
  }

  // ---------------------------------------------------------------------------
  // Firestore — Room metadata
  // ---------------------------------------------------------------------------

  /// Fetches the room document from Firestore.
  Future<Map<String, dynamic>> getRoomData(String roomId) async {
    final snap = await _firestore
        .collection(AppKeys.roomsCollection)
        .doc(roomId)
        .get();
    if (!snap.exists) throw Exception('Room not found.');
    return snap.data()!;
  }

  /// Removes the current user from the Firestore `participants` array.
  Future<void> removeParticipant(String roomId) async {
    await _firestore.collection(AppKeys.roomsCollection).doc(roomId).update({
      AppKeys.roomParticipants: FieldValue.arrayRemove([uid]),
    });
  }

  /// Returns `true` when the current UID matches [creatorId].
  bool isCreator(String creatorId) => uid == creatorId;
}
