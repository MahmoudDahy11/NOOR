import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../account_setup/domain/repositories/account_setup_repo.dart';
import '../../../../add_card/domain/repo/add_card_repo.dart';
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
  GoogleCubit(this.firebaseAuthrepo, this._accountSetupRepo, this._addCardRepo)
    : super(GoogleInitial());
  final FirebaseAuthRepo firebaseAuthrepo;
  final AccountSetupRepo _accountSetupRepo;
  final AddCardRepo _addCardRepo;

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
            await profileResult.fold(
              (failure) async => emit(GoogleSuccess(needsAccountSetup: true)),
              (exists) async {
                if (exists) {
                  final cardResult = await _addCardRepo.hasCard(user.uid);
                  cardResult.fold(
                    (failure) => emit(
                      GoogleSuccess(needsAccountSetup: false, needsAddCard: true),
                    ),
                    (hasCard) => emit(
                      GoogleSuccess(
                        needsAccountSetup: false,
                        needsAddCard: !hasCard,
                      ),
                    ),
                  );
                } else {
                  emit(GoogleSuccess(needsAccountSetup: true));
                }
              },
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
