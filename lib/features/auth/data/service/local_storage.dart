import 'package:hive_flutter/hive_flutter.dart';

/*
 * LocalStorageService class
 * manages local storage of user data using Hive
 * provides methods to save, retrieve, and clear user data
 * checks if a user is logged in
 * initializes Hive and opens the necessary box
 */
class LocalStorageService {
  // Keys for user data
  static const String _uidKey = 'uid';
  static const String _emailKey = 'email';
  static const String _nameKey = 'name';
  static const String _photoUrlKey = 'photoUrl';
  static const String _isLoggedInKey = 'isLoggedIn';

  // Keys for temporary data
  // static const String _seenOnboardingKey = 'seen_onboarding';
  // static const String _resetEmailKey = 'reset_email';
  // Box name for Hive storage
  static const String boxName = 'userBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Future<void> saveUserData({
    required String uid,
    required String email,
    String? name,
    String? photoUrl,
  }) async {
    final box = Hive.box(boxName);
    await box.put(_uidKey, uid);
    await box.put(_emailKey, email);
    await box.put(_nameKey, name ?? '');
    await box.put(_photoUrlKey, photoUrl ?? '');
    await box.put(_isLoggedInKey, true);
  }

  static bool isLoggedIn() {
    final box = Hive.box(boxName);
    return box.get(_isLoggedInKey, defaultValue: false) as bool;
  }

  static Map<String, dynamic> getUserData() {
    final box = Hive.box(boxName);
    return {
      'uid': box.get(_uidKey, defaultValue: ''),
      'email': box.get(_emailKey, defaultValue: ''),
      'name': box.get(_nameKey, defaultValue: ''),
      'photoUrl': box.get(_photoUrlKey, defaultValue: ''),
    };
  }

  static String? getUserId() {
    final box = Hive.box(boxName);
    final uid = box.get(_uidKey, defaultValue: '');
    return uid.isEmpty ? null : uid as String;
  }

  static String? getUserEmail() {
    final box = Hive.box(boxName);
    final email = box.get(_emailKey, defaultValue: '');
    return email.isEmpty ? null : email as String;
  }

  static Future<void> clearUserData() async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  // // ==================== Temporary Data Methods ====================

  // /// Sets the onboarding seen status
  // static Future<void> setSeenOnboarding(bool seen) async {
  //   final box = Hive.box(boxName);
  //   await box.put(_seenOnboardingKey, seen);
  // }

  // /// Gets whether the user has seen the onboarding screens
  // static bool hasSeenOnboarding() {
  //   final box = Hive.box(boxName);
  //   return box.get(_seenOnboardingKey, defaultValue: false) as bool;
  // }

  // /// Stores the email temporarily for password reset flow
  // static Future<void> setResetEmail(String email) async {
  //   final box = Hive.box(boxName);
  //   await box.put(_resetEmailKey, email);
  // }

  // /// Retrieves the temporarily stored reset email
  // static String? getResetEmail() {
  //   final box = Hive.box(boxName);
  //   final email = box.get(_resetEmailKey, defaultValue: '');
  //   return email.isEmpty ? null : email as String;
  // }

  // /// Clears the temporary reset email after verification
  // static Future<void> clearResetEmail() async {
  //   final box = Hive.box(boxName);
  //   await box.delete(_resetEmailKey);
  // }

}
