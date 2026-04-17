import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/account_setup_repo.dart';

part 'account_setup_state.dart';

class AccountSetupCubit extends Cubit<AccountSetupState> {
  final AccountSetupRepo _repo;

  AccountSetupCubit({required AccountSetupRepo repo})
    : _repo = repo,
      super(AccountSetupInitial());

  Future<void> saveProfile({
    required String displayName,
    required String avatarAsset,
    required String bio,
    required List<String> interests,
  }) async {
    emit(AccountSetupLoading());

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(const AccountSetupFailure('User not authenticated.'));
      return;
    }

    final result = await _repo.saveProfile(
      UserProfileEntity(
        uid: uid,
        displayName: displayName.trim(),
        avatarAsset: avatarAsset,
        bio: bio.trim(),
        interests: interests,
      ),
    );

    result.fold(
      (failure) => emit(AccountSetupFailure(failure.errMessage)),
      (_) => emit(AccountSetupSuccess()),
    );
  }
}
