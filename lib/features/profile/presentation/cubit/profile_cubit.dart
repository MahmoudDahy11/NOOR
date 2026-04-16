import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../auth/data/service/local_storage.dart';
import '../../../create_room/domain/repositories/create_room_repo.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repos/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;
  final CreateRoomRepo _createRoomRepo;
  StreamSubscription? _profileSubscription;

  ProfileCubit({
    required ProfileRepo profileRepo,
    required CreateRoomRepo createRoomRepo,
  }) : _profileRepo = profileRepo,
       _createRoomRepo = createRoomRepo,
       super(ProfileInitial());

  Future<void> getProfile() async {
    final uid = LocalStorageService.getUserId();
    if (uid == null) {
      emit(ProfileError(message: 'User session not found'));
      return;
    }

    _profileSubscription?.cancel();
    emit(ProfileLoading());

    _profileSubscription = _profileRepo.watchProfile(uid).listen((result) {
      result.fold(
        (failure) => emit(ProfileError(message: failure.errMessage)),
        (profile) => emit(ProfileSuccess(profile: profile)),
      );
    }, onError: (e) => emit(ProfileError(message: e.toString())));
  }

  Future<void> updateProfile(UserProfileEntity profile) async {
    // We don't need to emit ProfileLoading here if we want to avoid full screen shimmer
    // during background sync, but user might want a small indicator.
    // For now, we'll just call update, and the stream will push the new values.
    final result = await _profileRepo.updateProfile(profile);
    result.fold(
      (failure) => emit(ProfileError(message: failure.errMessage)),
      (_) => emit(ProfileUpdateSuccess()),
    );
  }

  Future<void> startRoom(String roomId) async {
    final result = await _createRoomRepo.startRoom(roomId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProfileError(message: failure.errMessage)),
      (_) => emit(ProfileRoomStartedSuccess(roomId: roomId)),
    );
  }

  Future<void> signOut() async {
    final result = await _profileRepo.signOut();
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProfileError(message: failure.errMessage)),
      (_) => emit(ProfileSignOutSuccess()),
    );
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
