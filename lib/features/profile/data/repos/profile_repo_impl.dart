import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../account_setup/data/models/user_profile_model.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../auth/data/service/local_storage.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repos/profile_repo.dart';
import '../datasource/profile_datasource.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ProfileDataSource _dataSource;

  ProfileRepoImpl({ProfileDataSource? dataSource})
    : _dataSource = dataSource ?? ProfileDataSource();

  @override
  Future<Either<CustomFailure, ProfileEntity>> getProfile(String uid) async {
    try {
      final userModel = await _dataSource.getUserProfile(uid);

      if (userModel == null) {
        return Left(CustomFailure(errMessage: 'User profile not found'));
      }

      // Get user stats
      final stats = await _dataSource.getUserStats(uid);

      // Get pending rooms
      final pendingRooms = await _dataSource.getPendingRooms(uid);

      final profile = ProfileEntity(
        user: userModel,
        roomsJoined: stats['roomsJoined'] ?? 0,
        totalCounts: stats['totalCounts'] ?? 0,
        roomsCreated: stats['roomsCreated'] ?? 0,
        pendingRooms: pendingRooms,
      );

      return Right(profile);
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> updateProfile(
    UserProfileEntity profile,
  ) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await _dataSource.updateUserProfile(model);
      return const Right(null);
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      await LocalStorageService.clearUserData();
      return const Right(null);
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }
}
