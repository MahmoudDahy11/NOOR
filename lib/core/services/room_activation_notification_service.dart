import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_keys.dart';
import 'local_notification_service.dart';

class RoomActivationNotificationService {
  RoomActivationNotificationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _notifyMeSubscription;
  final Map<String, _RoomWatchEntry> _roomWatchers = {};

  String? _activeUid;
  bool _isStarted = false;

  void start() {
    if (_isStarted) return;
    _isStarted = true;

    _authSubscription = _auth.authStateChanges().listen(_handleAuthChanged);
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _notifyMeSubscription?.cancel();

    for (final watcher in _roomWatchers.values) {
      await watcher.subscription?.cancel();
    }
    _roomWatchers.clear();
    _activeUid = null;
    _isStarted = false;
  }

  Future<void> _handleAuthChanged(User? user) async {
    final nextUid = user?.uid;
    if (_activeUid == nextUid) return;

    _activeUid = nextUid;
    await _notifyMeSubscription?.cancel();
    await _clearRoomWatchers();

    if (nextUid == null || nextUid.isEmpty) {
      return;
    }

    _notifyMeSubscription = _firestore
        .collectionGroup(AppKeys.notifyMeCollection)
        .where(AppKeys.userId, isEqualTo: nextUid)
        .snapshots()
        .listen((snapshot) => _syncRoomWatchers(nextUid, snapshot.docs));
  }

  Future<void> _syncRoomWatchers(
    String uid,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final nextRoomIds = <String>{};

    for (final doc in docs) {
      final data = doc.data();
      final roomId =
          data[AppKeys.notificationRoomId]?.toString() ??
          doc.reference.parent.parent?.id;
      if (roomId == null || roomId.isEmpty) {
        continue;
      }

      nextRoomIds.add(roomId);

      final existingWatcher = _roomWatchers[roomId];
      final hasDelivered = data[AppKeys.notifyMeNotifiedAt] != null;

      if (existingWatcher != null) {
        existingWatcher
          ..notifyMeRef = doc.reference
          ..hasDeliveredNotification = hasDelivered;
        continue;
      }

      _roomWatchers[roomId] = _createRoomWatcher(
        uid: uid,
        roomId: roomId,
        notifyMeRef: doc.reference,
        hasDeliveredNotification: hasDelivered,
      );
    }

    final staleRoomIds = _roomWatchers.keys
        .where((roomId) => !nextRoomIds.contains(roomId))
        .toList();

    for (final roomId in staleRoomIds) {
      final watcher = _roomWatchers.remove(roomId);
      await watcher?.subscription?.cancel();
    }
  }

  _RoomWatchEntry _createRoomWatcher({
    required String uid,
    required String roomId,
    required DocumentReference<Map<String, dynamic>> notifyMeRef,
    required bool hasDeliveredNotification,
  }) {
    final watcher = _RoomWatchEntry(
      notifyMeRef: notifyMeRef,
      hasDeliveredNotification: hasDeliveredNotification,
      subscription: null,
    );

    watcher.subscription = _firestore
        .collection(AppKeys.roomsCollection)
        .doc(roomId)
        .snapshots()
        .listen((snapshot) async {
          if (!snapshot.exists) {
            return;
          }

          final roomData = snapshot.data();
          if (roomData == null) {
            return;
          }

          final roomStatus = roomData[AppKeys.roomStatus] as String?;
          if (roomStatus != AppKeys.statusActive) {
            return;
          }

          if (watcher.hasDeliveredNotification || watcher.isDelivering) {
            return;
          }

          watcher.isDelivering = true;
          try {
            final created = await _storeRoomStartedNotification(
              uid: uid,
              roomId: roomId,
              roomData: roomData,
              notifyMeRef: watcher.notifyMeRef,
            );

            watcher.hasDeliveredNotification = true;

            if (created) {
              final roomName =
                  roomData[AppKeys.roomName]?.toString().trim().isNotEmpty ==
                      true
                  ? roomData[AppKeys.roomName].toString().trim()
                  : 'Your room';
              await LocalNotificationService.showHeadsUpNotification(
                id: _notificationIdForRoom(roomId),
                title: 'Room Started',
                body: '$roomName is live now. Join when you are ready.',
                payload: LocalNotificationService.buildRoomPayload(roomId),
              );
            }
          } finally {
            watcher.isDelivering = false;
          }
        });
    return watcher;
  }

  Future<bool> _storeRoomStartedNotification({
    required String uid,
    required String roomId,
    required Map<String, dynamic> roomData,
    required DocumentReference<Map<String, dynamic>> notifyMeRef,
  }) async {
    final roomName = roomData[AppKeys.roomName]?.toString().trim();
    final startedAt = (roomData[AppKeys.roomStartedAt] as Timestamp?)?.toDate();
    final notificationId =
        'room_started_${roomId}_${(startedAt ?? DateTime.now()).millisecondsSinceEpoch}';
    final notificationRef = _firestore
        .collection(AppKeys.usersCollection)
        .doc(uid)
        .collection(AppKeys.notificationsCollection)
        .doc(notificationId);

    return _firestore.runTransaction((transaction) async {
      final existingNotification = await transaction.get(notificationRef);
      if (existingNotification.exists) {
        transaction.set(notifyMeRef, {
          AppKeys.notifyMeNotifiedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return false;
      }

      transaction.set(notificationRef, {
        AppKeys.notificationId: notificationId,
        AppKeys.notificationTitle: 'Room Started',
        AppKeys.notificationBody:
            '${(roomName == null || roomName.isEmpty) ? 'Your room' : roomName} is live now. Join when you are ready.',
        AppKeys.notificationType: AppKeys.notificationTypeRoomStarted,
        AppKeys.notificationRoomId: roomId,
        AppKeys.notificationIsRead: false,
        AppKeys.notificationSentAt: FieldValue.serverTimestamp(),
      });
      transaction.set(notifyMeRef, {
        AppKeys.notifyMeNotifiedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    });
  }

  int _notificationIdForRoom(String roomId) => roomId.hashCode & 0x7fffffff;

  Future<void> _clearRoomWatchers() async {
    for (final watcher in _roomWatchers.values) {
      await watcher.subscription?.cancel();
    }
    _roomWatchers.clear();
  }
}

class _RoomWatchEntry {
  _RoomWatchEntry({
    required this.notifyMeRef,
    required this.hasDeliveredNotification,
    required this.subscription,
  });

  DocumentReference<Map<String, dynamic>> notifyMeRef;
  bool hasDeliveredNotification;
  bool isDelivering = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? subscription;
}
