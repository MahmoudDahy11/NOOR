import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepo {
  /*
   * Retrieves the user profile information for the given UID
   * Returns Either a CustomFailure or a ProfileEntity on success
   * Interacts with the data source (e.g., Firestore) to fetch the profile data
   */
  Future<Either<CustomFailure, ProfileEntity>> getProfile(String uid);
  /*
   * Watches the user profile information in real-time
   * Returns a Stream of Either a CustomFailure or a ProfileEntity
   */
  Stream<Either<CustomFailure, ProfileEntity>> watchProfile(String uid);
  /*
   * Updates the user profile information
   * Takes a UserProfileEntity as input and returns Either a CustomFailure or void on success
   * Interacts with the data source (e.g., Firestore) to persist the updated profile data
   */
  Future<Either<CustomFailure, void>> updateProfile(UserProfileEntity profile);
  /*
   * Signs out the current user
   * Returns Either a CustomFailure or void on success
   * Interacts with the authentication service to perform sign-out operations
   */
  Future<Either<CustomFailure, void>> signOut();
}
