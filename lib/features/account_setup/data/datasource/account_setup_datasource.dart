import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/user_profile_model.dart';

/// AccountSetup Data Source - Direct Firestore operations
class AccountSetupDataSource {
  final FirebaseFirestore _firestore;

  AccountSetupDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save user profile to Firestore
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      await _firestore
          .collection(AppKeys.usersCollection)
          .doc(profile.uid)
          .set(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  /// Check if user profile exists in Firestore
  Future<bool> hasUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppKeys.usersCollection)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check profile existence: $e');
    }
  }

  /// Get user profile from Firestore
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppKeys.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc.data() ?? {}, doc.id);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
}
