import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../account_setup/domain/repositories/account_setup_repo.dart';
import '../../../domain/repo/auth_repo.dart';
part 'google_state.dart';


/*
 * GoogleCubit class
 * extends Cubit with GoogleState
 * manages the state for Google sign-in
 * uses FirebaseAuthRepo for authentication operations
 * emits loading, success, and failure states based on the sign-in process
 */
class GoogleCubit extends Cubit<GoogleState> {
  GoogleCubit(this.firebaseAuthrepo, this._accountSetupRepo) : super(GoogleInitial());
  final FirebaseAuthRepo firebaseAuthrepo;
  final AccountSetupRepo _accountSetupRepo;

  Future<void> signInWithGoogle() async {
    try {
      if (isClosed) return;
      emit(GoogleLoading());
      
      final result = await firebaseAuthrepo.signInWithGoogle();
      
      if (isClosed) return;

      await result.fold(
        (failure) async => emit(GoogleFailure(errMessage: failure.errMessage)),
        (unit) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final profileResult = await _accountSetupRepo.hasUserProfile(user.uid);
            profileResult.fold(
              (failure) => emit(GoogleSuccess(needsAccountSetup: true)),
              (exists) => emit(GoogleSuccess(needsAccountSetup: !exists)),
            );
          } else {
            emit(GoogleSuccess());
          }
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(GoogleFailure(errMessage: e.toString()));
      }
    }
  }
}
