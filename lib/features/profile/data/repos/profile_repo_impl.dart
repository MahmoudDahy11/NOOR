import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/error/failure.dart';
import '../../../account_setup/data/models/user_profile_model.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../auth/data/service/local_storage.dart';
import '../../../auth/domain/repo/auth_repo.dart';
import '../../../create_room/data/models/room_model.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repos/profile_repo.dart';
import '../datasource/profile_datasource.dart';

class ProfileRepoImpl implements ProfileRepo {
  ProfileRepoImpl({
    required ProfileDataSource dataSource,
    required FirebaseAuthRepo authRepo,
  }) : _dataSource = dataSource,
       _authRepo = authRepo;

  final ProfileDataSource _dataSource;
  final FirebaseAuthRepo _authRepo;

  @override
  Stream<Either<CustomFailure, ProfileEntity>> watchProfile(String uid) =>
      Rx.combineLatest4(
        _dataSource.watchUserProfile(uid),
        _dataSource.watchCreatedRooms(uid),
        _dataSource.watchJoinedRooms(uid),
        _dataSource.watchTotalCounts(uid),
        _mapProfile,
      ).onErrorReturnWith(
        (error, _) => left(CustomFailure(errMessage: error.toString())),
      );

  @override
  Future<Either<CustomFailure, ProfileEntity>> getProfile(String uid) async {
    try {
      final user = await _dataSource.getUserProfile(uid);
      if (user == null) {
        return left(CustomFailure(errMessage: 'User profile not found'));
      }
      final created = await _dataSource.getCreatedRooms(uid);
      final joined = await _dataSource.getJoinedRooms(uid);
      final totalCounts = await _dataSource.getTotalCounts(uid);
      return right(_buildProfile(user, created, joined, totalCounts));
    } catch (error) {
      return left(CustomFailure(errMessage: error.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> updateProfile(
    UserProfileEntity profile,
  ) async {
    try {
      await _dataSource.updateUserProfile(UserProfileModel.fromEntity(profile));
      return right(null);
    } catch (error) {
      return left(CustomFailure(errMessage: error.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> signOut() async {
    final result = await _authRepo.signOut();
    return await result.fold((failure) async => left(failure), (_) async {
      await LocalStorageService.clearUserData();
      return right(null);
    });
  }

  Either<CustomFailure, ProfileEntity> _mapProfile(
    UserProfileModel? user,
    List<RoomModel> created,
    List<RoomModel> joined,
    int totalCounts,
  ) => user == null
      ? left(CustomFailure(errMessage: 'User profile not found'))
      : right(_buildProfile(user, created, joined, totalCounts));

  ProfileEntity _buildProfile(
    UserProfileEntity user,
    List<RoomModel> created,
    List<RoomModel> joined,
    int totalCounts,
  ) => ProfileEntity(
    user: user,
    roomsJoined: joined.length,
    totalCounts: totalCounts,
    roomsCreated: created.length,
    pendingRooms: created
        .where((room) => room.status == AppKeys.statusPending)
        .toList(),
  );
}
