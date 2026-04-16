import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../auth/data/service/local_storage.dart';
import '../../../create_room/domain/repositories/create_room_repo.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repos/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepo profileRepo,
    required CreateRoomRepo createRoomRepo,
  }) : _profileRepo = profileRepo,
       _createRoomRepo = createRoomRepo,
       super(const ProfileState());

  final ProfileRepo _profileRepo;
  final CreateRoomRepo _createRoomRepo;
  StreamSubscription<Either<CustomFailure, ProfileEntity>>? _subscription;

  Future<void> getProfile() async {
    final uid = LocalStorageService.getUserId();
    if (uid == null) return _emitFailure('User session not found');
    await _subscription?.cancel();
    if (state.profile == null) {
      emit(
        state.copyWith(
          loadStatus: ProfileLoadStatus.loading,
          outcome: ProfileOutcome.none,
        ),
      );
    }
    _subscription = _profileRepo
        .watchProfile(uid)
        .listen(
          (result) => result.fold(
            (failure) => _emitFailure(failure.errMessage),
            _emitLoaded,
          ),
          onError: (error) => _emitFailure(error.toString()),
        );
  }

  Future<void> updateProfile(UserProfileEntity profile) async {
    emit(
      state.copyWith(
        actionStatus: ProfileActionStatus.saving,
        outcome: ProfileOutcome.none,
      ),
    );
    final result = await _profileRepo.updateProfile(profile);
    result.fold(
      (failure) => _emitFailure(failure.errMessage),
      (_) => _emitOutcome(ProfileOutcome.updated),
    );
  }

  Future<void> startRoom(String roomId) async {
    emit(
      state.copyWith(
        actionStatus: ProfileActionStatus.startingRoom,
        outcome: ProfileOutcome.none,
      ),
    );
    final result = await _createRoomRepo.startRoom(roomId);
    result.fold(
      (failure) => _emitFailure(failure.errMessage),
      (_) => _emitOutcome(ProfileOutcome.roomStarted, roomId: roomId),
    );
  }

  Future<void> signOut() async {
    emit(
      state.copyWith(
        actionStatus: ProfileActionStatus.signingOut,
        outcome: ProfileOutcome.none,
      ),
    );
    final result = await _profileRepo.signOut();
    result.fold(
      (failure) => _emitFailure(failure.errMessage),
      (_) => _emitOutcome(ProfileOutcome.signedOut),
    );
  }

  void _emitLoaded(ProfileEntity profile) => emit(
    state.copyWith(
      profile: profile,
      loadStatus: ProfileLoadStatus.loaded,
      actionStatus: ProfileActionStatus.idle,
      outcome: ProfileOutcome.none,
      message: null,
      reactionId: state.reactionId,
    ),
  );

  void _emitOutcome(ProfileOutcome outcome, {String? roomId}) => emit(
    state.copyWith(
      loadStatus: state.profile == null
          ? ProfileLoadStatus.failure
          : ProfileLoadStatus.loaded,
      actionStatus: ProfileActionStatus.idle,
      outcome: outcome,
      message: null,
      startedRoomId: roomId,
      reactionId: state.reactionId + 1,
    ),
  );

  void _emitFailure(String message) => emit(
    state.copyWith(
      loadStatus: state.profile == null
          ? ProfileLoadStatus.failure
          : ProfileLoadStatus.loaded,
      actionStatus: ProfileActionStatus.idle,
      outcome: ProfileOutcome.error,
      message: message,
      reactionId: state.reactionId + 1,
    ),
  );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
