import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../account_setup/data/models/user_profile_model.dart';
import '../../../create_room/data/models/room_model.dart';

/// Profile Data Source - Firestore operations for user profiles
class ProfileDataSource {
  final FirebaseFirestore _firestore;

  ProfileDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user profile from Firestore as a Stream
  Stream<UserProfileModel?> watchUserProfile(String uid) {
    return _firestore
        .collection(AppKeys.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfileModel.fromFirestore(doc.data() ?? {}) : null);
  }

  /// Get user profile from Firestore
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(AppKeys.usersCollection).doc(uid).get();
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc.data() ?? {});
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(UserProfileModel profile) async {
    try {
      await _firestore
          .collection(AppKeys.usersCollection)
          .doc(profile.uid)
          .update(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Sign out (revoke session data if any)
  Future<void> signOut() async {
    try {
      // Any cleanup if needed
      // This method can be extended for additional cleanup
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Get user stats (rooms created, joined, etc.)
  Future<Map<String, dynamic>> getUserStats(String uid) async {
    try {
      // For now, returning placeholder stats
      // This can be extended to fetch from Firestore collections like 'rooms', 'participations', etc.
      return {
        AppKeys.userStatsRoomsCreated: 0,
        AppKeys.userStatsRoomsJoined: 0,
        AppKeys.userStatsTotalCounts: 0,
      };
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  /// Get user-created rooms that are in 'pending' status as a Stream
  Stream<List<RoomModel>> watchPendingRooms(String uid) {
    return _firestore
        .collection(AppKeys.roomsCollection)
        .where('${AppKeys.roomCreator}.${AppKeys.roomId}', isEqualTo: uid)
        .where(AppKeys.roomStatus, isEqualTo: AppKeys.statusPending)
        .orderBy(AppKeys.roomCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get user-created rooms that are in 'pending' status
  Future<List<RoomModel>> getPendingRooms(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(AppKeys.roomsCollection)
          .where('${AppKeys.roomCreator}.${AppKeys.roomId}', isEqualTo: uid)
          .where(AppKeys.roomStatus, isEqualTo: AppKeys.statusPending)
          .orderBy(AppKeys.roomCreatedAt, descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending rooms: $e');
    }
  }
}
