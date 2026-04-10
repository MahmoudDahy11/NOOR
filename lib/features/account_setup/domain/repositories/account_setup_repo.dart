import 'package:dartz/dartz.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../entities/user_profile_entity.dart';

abstract class AccountSetupRepo {
  Future<Either<CustomFailure, void>> saveProfile(UserProfileEntity profile);
  Future<Either<CustomFailure, bool>> hasUserProfile(String uid);
}
