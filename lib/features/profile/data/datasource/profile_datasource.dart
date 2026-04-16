import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../account_setup/data/models/user_profile_model.dart';
import '../../../create_room/data/models/room_model.dart';

class ProfileDataSource {
  ProfileDataSource({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  Stream<UserProfileModel?> watchUserProfile(String uid) =>
      _userDoc(uid).snapshots().map(
        (doc) => doc.exists
            ? UserProfileModel.fromFirestore(doc.data() ?? {})
            : null,
      );

  Stream<List<RoomModel>> watchCreatedRooms(String uid) =>
      _createdRoomsQuery(uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
            .toList(),
      );

  Stream<List<RoomModel>> watchJoinedRooms(String uid) =>
      _joinedRoomsQuery(uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
            .toList(),
      );

  Stream<int> watchTotalCounts(String uid) =>
      _userDoc(uid).snapshots().map((doc) => _readTotalCounts(doc.data()));

  Future<UserProfileModel?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromFirestore(doc.data() ?? {});
  }

  Future<List<RoomModel>> getCreatedRooms(String uid) async {
    final snapshot = await _createdRoomsQuery(uid).get();
    return snapshot.docs
        .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<RoomModel>> getJoinedRooms(String uid) async {
    final snapshot = await _joinedRoomsQuery(uid).get();
    return snapshot.docs
        .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<int> getTotalCounts(String uid) async =>
      _readTotalCounts((await _userDoc(uid).get()).data());

  Future<void> updateUserProfile(UserProfileModel profile) =>
      _userDoc(profile.uid).update(profile.toFirestore());

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(AppKeys.usersCollection).doc(uid);

  Query<Map<String, dynamic>> _createdRoomsQuery(String uid) => _db
      .collection(AppKeys.roomsCollection)
      .where('${AppKeys.roomCreator}.${AppKeys.roomId}', isEqualTo: uid)
      .orderBy(AppKeys.roomCreatedAt, descending: true);

  Query<Map<String, dynamic>> _joinedRoomsQuery(String uid) => _db
      .collection(AppKeys.roomsCollection)
      .where(AppKeys.roomParticipants, arrayContains: uid);

  int _readTotalCounts(Map<String, dynamic>? data) =>
      (data?[AppKeys.userStatsTotalCounts] as num?)?.toInt() ?? 0;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;
}
