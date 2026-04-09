import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entity/user_entity.dart';

/*
 * FirebaseAuthRepo interface
 * defines the contract for Firebase authentication repository
 * includes methods for user creation, sign-in, sign-out, and social authentication
 */
abstract class FirebaseAuthRepo {
  /* 
   * Method to create a user with email and password
   * returns Either a CustomFailure or UserEntity
   */
  Future<Either<CustomFailure, UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  /* 
   * Method to sign in a user with email and password
   * returns Either a CustomFailure or UserEntity
   */
  Future<Either<CustomFailure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  /* 
   * Method to sign out the current user
   * returns Either a CustomFailure or Unit
   */
  Future<Either<CustomFailure, Unit>> signOut();

  Future<Either<CustomFailure, void>> sendPasswordResetEmail(String email);

  Future<Either<CustomFailure, Unit>> signInWithGoogle();
  Future<Either<CustomFailure, UserEntity>> signinWithFacebook();
}
