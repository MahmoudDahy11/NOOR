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

  ProfileCubit({
    required ProfileRepo profileRepo,
    required CreateRoomRepo createRoomRepo,
  }) : _profileRepo = profileRepo,
       _createRoomRepo = createRoomRepo,
       super(ProfileInitial());

  Future<void> getProfile() async {
    emit(ProfileLoading());
    final uid = LocalStorageService.getUserId();

    if (uid == null) {
      if (!isClosed) {
        emit(ProfileError(message: 'User session not found'));
      }
      return;
    }

    final result = await _profileRepo.getProfile(uid);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProfileError(message: failure.errMessage)),
      (profile) => emit(ProfileSuccess(profile: profile)),
    );
  }

  Future<void> updateProfile(UserProfileEntity profile) async {
    emit(ProfileLoading());
    final result = await _profileRepo.updateProfile(profile);
    if (isClosed) return;
    result.fold((failure) => emit(ProfileError(message: failure.errMessage)), (
      _,
    ) {
      emit(ProfileUpdateSuccess());
      getProfile(); // Refresh profile after update
    });
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
}
