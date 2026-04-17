import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/error/custom_excption.dart';
import '../../../../core/services/push_token_service.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../model/user_model.dart';
import '../service/firebase_auth.dart';
import '../service/local_storage.dart';

class FirebaseAuthRepoImplement extends FirebaseAuthRepo {
  final FirebaseService _firebaseService;
  FirebaseAuthRepoImplement(this._firebaseService);

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  @override
  Future<Either<CustomFailure, UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _firebaseService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      UserModel userModel = UserModel.fromFirebase(user);
      userModel = UserModel(
        uId: userModel.uId,
        email: userModel.email,
        name: name,
      );
      return right(userModel.toEntity());
    } on CustomException catch (ex) {
      if (ex.errMessage.contains('email-already-in-use')) {
        return left(
          CustomFailure(
            errMessage:
                'This email is already registered. Please login or reset password.',
          ),
        );
      }
      return left(CustomFailure(errMessage: ex.errMessage));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await LocalStorageService.saveUserData(
        uid: user.uid,
        email: user.email!,
        name: user.displayName,
      );
      await PushTokenService.syncCurrentUserToken();

      UserModel userModel = UserModel.fromFirebase(user);
      userModel = UserModel(
        uId: userModel.uId,
        email: userModel.email,
        name: userModel.name,
      );

      return right(userModel.toEntity());
    } on CustomException catch (ex) {
      return left(CustomFailure(errMessage: ex.errMessage));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, Unit>> signOut() async {
    try {
      await PushTokenService.clearCurrentUserToken();
      await _firebaseService.signOut();
      return right(unit);
    } on CustomException catch (ex) {
      return left(CustomFailure(errMessage: ex.errMessage));
    }
  }

  @override
  Future<Either<CustomFailure, void>> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email: email);
      return right(null);
    } on CustomException catch (ex) {
      return left(CustomFailure(errMessage: ex.errMessage));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, Unit>> signInWithGoogle() async {
    try {
      final user = await _firebaseService.signInWithGoogle();

      await _firestore.collection(AppKeys.usersCollection).doc(user.uid).set({
        AppKeys.uId: user.uid,
        AppKeys.email: user.email,
        AppKeys.displayName: user.displayName ?? '',
        AppKeys.photoUrl: user.photoURL ?? '',
        AppKeys.userCreatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await LocalStorageService.saveUserData(
        uid: user.uid,
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
      );
      await PushTokenService.syncCurrentUserToken();

      return right(unit);
    } on CustomException catch (ex) {
      return left(CustomFailure(errMessage: ex.errMessage));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, UserEntity>> signinWithFacebook() async {
    try {
      final userCredential = await _firebaseService.signInWithFacebook();

      if (userCredential.user == null) {
        return left(
          CustomFailure(errMessage: "No user returned from Facebook login."),
        );
      }

      final UserModel userModel = UserModel.fromFirebase(userCredential.user!);

      await _firestore
          .collection(AppKeys.usersCollection)
          .doc(userCredential.user!.uid)
          .set({
            AppKeys.uId: userCredential.user!.uid,
            AppKeys.email: userCredential.user!.email,
            AppKeys.displayName: userCredential.user!.displayName ?? '',
            AppKeys.photoUrl: userCredential.user!.photoURL ?? '',
            AppKeys.userCreatedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      await PushTokenService.syncCurrentUserToken();

      return right(userModel.toEntity());
    } on CustomException catch (e) {
      return left(CustomFailure(errMessage: e.errMessage));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> deleteUserAccount(String password) async {
    try {
      await PushTokenService.clearCurrentUserToken();
      await _firebaseService.deleteUserAccount(password: password);
      return right(null);
    } on CustomException catch (ex) {
      return left(CustomFailure(errMessage: ex.errMessage));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
