import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../auth/data/service/local_storage.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repos/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;

  ProfileCubit({required ProfileRepo profileRepo})
      : _profileRepo = profileRepo,
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
    result.fold(
      (failure) => emit(ProfileError(message: failure.errMessage)),
      (_) {
        emit(ProfileUpdateSuccess());
        getProfile(); // Refresh profile after update
      },
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
