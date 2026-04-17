import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/app_keys.dart';

class PushTokenService {
  PushTokenService._();

  static Future<void> syncCurrentUserToken({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    String? token,
  }) async {
    final currentAuth = auth ?? FirebaseAuth.instance;
    final uid = currentAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final resolvedToken =
        token ?? await (messaging ?? FirebaseMessaging.instance).getToken();
    if (resolvedToken == null || resolvedToken.isEmpty) return;

    await (firestore ?? FirebaseFirestore.instance)
        .collection(AppKeys.usersCollection)
        .doc(uid)
        .set({
          AppKeys.userFcmToken: resolvedToken,
          AppKeys.userFcmTokenUpdatedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  static Future<void> clearCurrentUserToken({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) async {
    final currentAuth = auth ?? FirebaseAuth.instance;
    final uid = currentAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    await (firestore ?? FirebaseFirestore.instance)
        .collection(AppKeys.usersCollection)
        .doc(uid)
        .set({
          AppKeys.userFcmToken: FieldValue.delete(),
          AppKeys.userFcmTokenUpdatedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
