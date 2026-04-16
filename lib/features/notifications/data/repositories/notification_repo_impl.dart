import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notification_repo.dart';
import '../models/app_notification_model.dart';

class NotificationRepoImpl implements NotificationRepo {
  NotificationRepoImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _notificationsRef(String uid) {
    return _firestore
        .collection(AppKeys.usersCollection)
        .doc(uid)
        .collection(AppKeys.notificationsCollection);
  }

  @override
  Stream<int> watchUnreadCount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Stream<int>.value(0);
    }

    return _notificationsRef(uid)
        .where(AppKeys.notificationIsRead, isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Stream<List<AppNotificationEntity>> watchNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Stream<List<AppNotificationEntity>>.value(const []);
    }

    return _notificationsRef(uid)
        .orderBy(AppKeys.notificationSentAt, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AppNotificationModel.fromFirestore(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    await _notificationsRef(uid).doc(notificationId).set({
      AppKeys.notificationIsRead: true,
      AppKeys.notificationOpenedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
