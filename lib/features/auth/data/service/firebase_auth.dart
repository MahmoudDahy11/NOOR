import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/custom_excption.dart';
import 'local_storage.dart';

/*
 * FirebaseService class
 * handles user authentication with Firebase
 * supports email/password, Google, and Facebook sign-in methods
 * rest the password 
 * manages user data in Firestore
 * saves user session data locally using LocalStorageService
 * throws CustomException on errors with appropriate messages
 */
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestoreInstance => firestore;

  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw CustomException(errMessage: 'User creation failed.');
      }

      try {
        await user.updateDisplayName(name);
      } catch (e) {
        log("⚠️ Warning: Could not update display name: $e");
        // Continue anyway - display name update is not critical
      }

      log("✅ User created: ${user.email}");
      return user;
    } on FirebaseAuthException catch (e) {
      throw CustomException(errMessage: e.message ?? 'Firebase Auth error');
    } catch (e) {
      throw CustomException(errMessage: 'Error creating user: $e');
    }
  }

  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw CustomException(errMessage: 'Sign in failed');

      return user;
    } on FirebaseAuthException catch (e) {
      throw CustomException(errMessage: e.message ?? 'Firebase Auth error');
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw CustomException(errMessage: "Google sign-in cancelled.");
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw CustomException(errMessage: "No user returned from Firebase.");
      }

      return user;
    } catch (e) {
      throw CustomException(errMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw CustomException(errMessage: e.toString());
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      final userDoc = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        throw CustomException(
          errMessage: 'This email is not registered in our database.',
        );
      }
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw CustomException(
        errMessage: e.message ?? 'An error occurred during password reset.',
      );
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(errMessage: e.toString());
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      log("Facebook login status: ${result.status}");
      log("Facebook login message: ${result.message}");
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);

        final user = userCredential.user!;
        await LocalStorageService.saveUserData(
          uid: user.uid,
          email: user.email!,
          name: user.displayName,
          photoUrl: user.photoURL,
        );

        return userCredential;
      } else if (result.status == LoginStatus.cancelled) {
        throw CustomException(errMessage: 'Facebook sign-in was cancelled.');
      } else {
        throw CustomException(
          errMessage: result.message ?? 'Unknown Facebook login error.',
        );
      }
    } catch (e) {
      throw CustomException(errMessage: e.toString());
    }
  }

  Future<void> deleteUserAccount({required String password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw CustomException(errMessage: 'No authenticated user found.');
      }

      // 1. Re-authenticate the user
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Delete user's document from Firestore
      final uid = user.uid;
      await firestore.collection('users').doc(uid).delete();

      // 3. Delete the user from FirebaseAuth
      await user.delete();

      // 4. Clear local session/cache
      await LocalStorageService.clearUserData();

      log("✅ User account deleted and session cleared: $uid");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw CustomException(
          errMessage: 'The password you entered is incorrect.',
        );
      } else if (e.code == 'requires-recent-login') {
        throw CustomException(
          errMessage:
              'This operation is sensitive and requires recent authentication. Please log in again.',
        );
      }
      throw CustomException(errMessage: e.message ?? 'Authentication error');
    } catch (e) {
      throw CustomException(
        errMessage: 'Error deleting account: ${e.toString()}',
      );
    }
  }
}
