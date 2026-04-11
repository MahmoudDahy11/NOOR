import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../account_setup/domain/repositories/account_setup_repo.dart';
import '../../../domain/entity/user_entity.dart';
import '../../../domain/repo/auth_repo.dart';

part 'facebook_state.dart';

/*
 * FacebookCubit class
 * extends Cubit with FacebookState
 * manages the state for Facebook sign-in
 * uses FirebaseAuthRepo for authentication operations
 * emits loading, success, and failure states based on the sign-in process
 */
class FacebookCubit extends Cubit<FacebookState> {
  FacebookCubit(this.firebaseAuthrepo, this._accountSetupRepo) : super(FacebookInitial());
  final FirebaseAuthRepo firebaseAuthrepo;
  final AccountSetupRepo _accountSetupRepo;

  Future<void> signInWithFacebook() async {
    try {
      if (isClosed) return;
      emit(FacebookLoading());
      
      final result = await firebaseAuthrepo.signinWithFacebook();
      
      if (isClosed) return;

      await result.fold(
        (failure) async => emit(FacebookFailure(errMessage: failure.errMessage)),
        (user) async {
          final profileResult = await _accountSetupRepo.hasUserProfile(user.uId);
          profileResult.fold(
            (failure) => emit(FacebookSuccess(user: user, needsAccountSetup: true)),
            (exists) => emit(FacebookSuccess(user: user, needsAccountSetup: !exists)),
          );
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(FacebookFailure(errMessage: e.toString()));
      }
    }
  }
}
