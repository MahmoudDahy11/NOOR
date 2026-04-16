import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_islamic/core/error/failure.dart';
import 'package:tally_islamic/features/account_setup/data/models/user_profile_model.dart';
import 'package:tally_islamic/features/auth/domain/repo/auth_repo.dart';
import 'package:tally_islamic/features/create_room/data/models/room_model.dart';
import 'package:tally_islamic/features/profile/data/datasource/profile_datasource.dart';
import 'package:tally_islamic/features/profile/data/repos/profile_repo_impl.dart';

import 'profile_support.dart';

void main() {
  test(
    'watchProfile derives counts and pending rooms from source streams',
    () async {
      final dataSource = FakeProfileDataSource();
      final repo = ProfileRepoImpl(
        dataSource: dataSource,
        authRepo: FakeAuthRepo(),
      );
      expectLater(
        repo.watchProfile('user-1'),
        emits(
          isA<Right<CustomFailure, dynamic>>().having(
            (value) => value
                .getOrElse(() => throw StateError('expected profile'))
                .roomsCreated,
            'roomsCreated',
            2,
          ),
        ),
      );
      dataSource.user.add(UserProfileModel.fromEntity(sampleUser()));
      dataSource.created.add([
        roomModel(),
        roomModel(id: 'room-2', status: 'active'),
      ]);
      dataSource.joined.add([roomModel(id: 'room-1'), roomModel(id: 'room-3')]);
      dataSource.totalCounts.add(14);
    },
  );

  test(
    'watchProfile falls back to zero total counts and fails when user is missing',
    () async {
      final dataSource = FakeProfileDataSource();
      final repo = ProfileRepoImpl(
        dataSource: dataSource,
        authRepo: FakeAuthRepo(),
      );
      expectLater(
        repo.watchProfile('user-1'),
        emitsInOrder([
          isA<Left<CustomFailure, dynamic>>(),
          isA<Right<CustomFailure, dynamic>>().having(
            (value) => value
                .getOrElse(() => throw StateError('expected profile'))
                .totalCounts,
            'totalCounts',
            0,
          ),
        ]),
      );
      dataSource.created.add([roomModel()]);
      dataSource.joined.add([roomModel()]);
      dataSource.totalCounts.add(0);
      dataSource.user.add(null);
      dataSource.user.add(UserProfileModel.fromEntity(sampleUser()));
    },
  );
}

class FakeProfileDataSource extends ProfileDataSource {
  final user = StreamController<UserProfileModel?>();
  final created = StreamController<List<RoomModel>>();
  final joined = StreamController<List<RoomModel>>();
  final totalCounts = StreamController<int>();

  @override
  Stream<UserProfileModel?> watchUserProfile(String uid) => user.stream;
  @override
  Stream<List<RoomModel>> watchCreatedRooms(String uid) => created.stream;
  @override
  Stream<List<RoomModel>> watchJoinedRooms(String uid) => joined.stream;
  @override
  Stream<int> watchTotalCounts(String uid) => totalCounts.stream;
}

class FakeAuthRepo extends Fake implements FirebaseAuthRepo {}

RoomModel roomModel({String id = 'room-1', String status = 'pending'}) =>
    RoomModel(
      id: id,
      name: 'Morning Circle',
      type: 'free',
      dhikr: 'SubhanAllah',
      goal: 100,
      currentProgress: 0,
      creator: const RoomCreatorModel(id: 'user-1', name: 'Maha', photo: ''),
      createdAt: DateTime(2024),
      status: status,
      isPublic: true,
      participants: const ['user-1'],
      durationHours: 1,
    );
