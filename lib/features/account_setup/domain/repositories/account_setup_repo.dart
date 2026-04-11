import 'package:dartz/dartz.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../entities/user_profile_entity.dart';

abstract class AccountSetupRepo {
  /*
   * Saves the user profile information
   * Takes a UserProfileEntity as input and returns Either a CustomFailure or void on success
   * Interacts with the data source (e.g., Firestore) to persist the profile data
   */
  Future<Either<CustomFailure, void>> saveProfile(UserProfileEntity profile);
  /*
   * Checks if a user profile exists for the given UID
   * Returns Either a CustomFailure or a boolean indicating existence
   * Interacts with the data source (e.g., Firestore) to verify profile presence
   */
  Future<Either<CustomFailure, bool>> hasUserProfile(String uid);
}
