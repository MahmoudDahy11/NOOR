import 'package:dartz/dartz.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/account_setup_repo.dart';
import '../datasource/account_setup_datasource.dart';
import '../models/user_profile_model.dart';

class AccountSetupRepoImpl implements AccountSetupRepo {
  final AccountSetupDataSource _dataSource;

  AccountSetupRepoImpl({AccountSetupDataSource? dataSource})
    : _dataSource = dataSource ?? AccountSetupDataSource();

  @override
  Future<Either<CustomFailure, void>> saveProfile(
    UserProfileEntity profile,
  ) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await _dataSource.saveProfile(model);
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, bool>> hasUserProfile(String uid) async {
    try {
      final exists = await _dataSource.hasUserProfile(uid);
      return Right(exists);
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }
}
