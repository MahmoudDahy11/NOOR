import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../../../core/error/custom_excption.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../model/user_model.dart';
import '../service/firebase_auth.dart';
import '../service/local_storage.dart';
import '../service/otp_service.dart';

class FirebaseAuthRepoImplement extends FirebaseAuthRepo {
  final FirebaseService _firebaseService;
  FirebaseAuthRepoImplement(this._firebaseService);

  FirebaseFirestore get _firestore => _firebaseService.firestore;
  User? get _currentUser => FirebaseAuth.instance.currentUser;
  final _otpService = OtpService();

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
      await _firebaseService.signOut();
      return right(unit);
    } on CustomException catch (ex) {
      return left(CustomFailure(errMessage: ex.errMessage));
    }
  }

  @override
  Future<Either<CustomFailure, Unit>> forgetPassword({
    required String newPassword,
  }) async {
    try {
      final user = _currentUser;
      if (user == null) {
        return left(CustomFailure(errMessage: 'User is not authenticated.'));
      }

      final otp = _otpService.generateOtp();
      await _otpService.saveOtp(user.uid, otp);
      await _otpService.sendOtpToEmail(user.email!, otp);

      await _firebaseService.forgetPassword(newPassword: newPassword);

      return right(unit);
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

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await LocalStorageService.saveUserData(
        uid: user.uid,
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
      );

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

      return right(userModel.toEntity());
    } on CustomException catch (e) {
      return left(CustomFailure(errMessage: e.errMessage));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
