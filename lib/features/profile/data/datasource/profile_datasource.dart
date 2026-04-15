import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../account_setup/data/models/user_profile_model.dart';

/// Profile Data Source - Firestore operations for user profiles
class ProfileDataSource {
  final FirebaseFirestore _firestore;

  ProfileDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user profile from Firestore
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
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
          .collection('users')
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
      return {'roomsCreated': 0, 'roomsJoined': 0, 'totalCounts': 0};
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }
}
