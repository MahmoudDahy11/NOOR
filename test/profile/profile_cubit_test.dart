import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tally_islamic/core/error/failure.dart';
import 'package:tally_islamic/features/auth/data/service/local_storage.dart';
import 'package:tally_islamic/features/profile/domain/entities/profile_entity.dart';
import 'package:tally_islamic/features/profile/presentation/cubit/profile_cubit.dart';

import 'profile_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init('${Directory.systemTemp.path}/tally_profile_tests');
    if (!Hive.isBoxOpen(LocalStorageService.boxName)) {
      await Hive.openBox(LocalStorageService.boxName);
    }
  });
  setUp(() async {
    await LocalStorageService.clearUserData();
    await LocalStorageService.saveUserData(
      uid: 'user-1',
      email: 'maha@test.com',
    );
  });

  test('getProfile goes from loading to loaded', () async {
    final controller = StreamController<Either<CustomFailure, ProfileEntity>>();
    final repo = StubProfileRepo()..watchStream = controller.stream.cast();
    final cubit = ProfileCubit(
      profileRepo: repo,
      createRoomRepo: StubCreateRoomRepo(),
    );
    expectLater(
      cubit.stream,
      emitsThrough(
        predicate<ProfileState>(
          (state) =>
              state.profile != null &&
              state.loadStatus == ProfileLoadStatus.loaded,
        ),
      ),
    );
    await cubit.getProfile();
    controller.add(right(sampleProfile()));
  });

  test(
    'update, room start, and sign out keep profile on failures and expose outcomes',
    () async {
      final repo = StubProfileRepo()
        ..updateResult = left(CustomFailure(errMessage: 'save failed'))
        ..signOutResult = left(CustomFailure(errMessage: 'logout failed'));
      final rooms = StubCreateRoomRepo()
        ..startRoomResult = left(CustomFailure(errMessage: 'room failed'));
      final cubit = TestProfileCubit(profileRepo: repo, createRoomRepo: rooms);
      cubit.push(
        const ProfileState().copyWith(
          profile: sampleProfile(),
          loadStatus: ProfileLoadStatus.loaded,
        ),
      );
      await cubit.updateProfile(sampleUser());
      expect(cubit.state.profile, isNotNull);
      expect(cubit.state.outcome, ProfileOutcome.error);
      await cubit.startRoom('room-1');
      expect(cubit.state.profile, isNotNull);
      await cubit.signOut();
      expect(cubit.state.profile, isNotNull);
    },
  );
}
