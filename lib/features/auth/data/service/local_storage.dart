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
}
