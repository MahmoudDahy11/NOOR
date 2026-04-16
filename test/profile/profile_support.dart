import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_islamic/core/error/failure.dart';
import 'package:tally_islamic/features/account_setup/domain/entities/user_profile_entity.dart';
import 'package:tally_islamic/features/create_room/domain/entities/create_room_params.dart';
import 'package:tally_islamic/features/create_room/domain/entities/room_entity.dart';
import 'package:tally_islamic/features/create_room/domain/repositories/create_room_repo.dart';
import 'package:tally_islamic/features/profile/domain/entities/profile_entity.dart';
import 'package:tally_islamic/features/profile/domain/repos/profile_repo.dart';
import 'package:tally_islamic/features/profile/presentation/cubit/profile_cubit.dart';

UserProfileEntity sampleUser() => const UserProfileEntity(
  uid: 'user-1',
  displayName: 'Maha',
  avatarAsset: 'assets/avatars/avatar_1.svg',
  bio: 'Daily dhikr',
  interests: ['Dhikr', 'Quran'],
);

RoomEntity sampleRoom({String id = 'room-1', String status = 'pending'}) =>
    RoomEntity(
      id: id,
      name: 'Morning Circle',
      type: 'free',
      dhikr: 'SubhanAllah',
      goal: 100,
      currentProgress: 0,
      creator: const RoomCreatorEntity(id: 'user-1', name: 'Maha', photo: ''),
      createdAt: DateTime(2024),
      status: status,
      isPublic: true,
      participants: const ['user-1'],
      durationHours: 1,
    );

ProfileEntity sampleProfile({
  int joined = 2,
  int counts = 9,
  int created = 3,
}) => ProfileEntity(
  user: sampleUser(),
  roomsJoined: joined,
  totalCounts: counts,
  roomsCreated: created,
  pendingRooms: [sampleRoom()],
);

class StubProfileRepo extends Fake implements ProfileRepo {
  Stream<Either<CustomFailure, ProfileEntity>> watchStream =
      const Stream.empty();
  Either<CustomFailure, void> updateResult = right(null);
  Either<CustomFailure, void> signOutResult = right(null);

  @override
  Future<Either<CustomFailure, ProfileEntity>> getProfile(String uid) async =>
      right(sampleProfile());
  @override
  Stream<Either<CustomFailure, ProfileEntity>> watchProfile(String uid) =>
      watchStream;
  @override
  Future<Either<CustomFailure, void>> updateProfile(
    UserProfileEntity profile,
  ) async => updateResult;
  @override
  Future<Either<CustomFailure, void>> signOut() async => signOutResult;
}

class StubCreateRoomRepo extends Fake implements CreateRoomRepo {
  Either<CustomFailure, void> startRoomResult = right(null);

  @override
  Future<Either<CustomFailure, RoomEntity>> createRoom(
    CreateRoomParams params,
  ) async => throw UnimplementedError();
  @override
  Future<Either<CustomFailure, List<RoomEntity>>> getMyRooms() async =>
      right([sampleRoom()]);
  @override
  Future<Either<CustomFailure, void>> startRoom(String roomId) async =>
      startRoomResult;
}

class TestProfileCubit extends ProfileCubit {
  TestProfileCubit({required super.profileRepo, required super.createRoomRepo});
  void push(ProfileState state) => emit(state);
}
