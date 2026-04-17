import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../account_setup/domain/repositories/account_setup_repo.dart';
import '../../../../add_card/domain/repo/add_card_repo.dart';
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
  FacebookCubit(
    this.firebaseAuthrepo,
    this._accountSetupRepo,
    this._addCardRepo,
  ) : super(FacebookInitial());
  final FirebaseAuthRepo firebaseAuthrepo;
  final AccountSetupRepo _accountSetupRepo;
  final AddCardRepo _addCardRepo;

  Future<void> signInWithFacebook() async {
    try {
      if (isClosed) return;
      emit(FacebookLoading());

      final result = await firebaseAuthrepo.signinWithFacebook();

      if (isClosed) return;

      await result.fold(
        (failure) async =>
            emit(FacebookFailure(errMessage: failure.errMessage)),
        (user) async {
          final profileResult = await _accountSetupRepo.hasUserProfile(
            user.uId,
          );
          await profileResult.fold(
            (failure) async =>
                emit(FacebookSuccess(user: user, needsAccountSetup: true)),
            (exists) async {
              if (exists) {
                final cardResult = await _addCardRepo.hasCard(user.uId);
                cardResult.fold(
                  (failure) => emit(
                    FacebookSuccess(
                      user: user,
                      needsAccountSetup: false,
                      needsAddCard: true,
                    ),
                  ),
                  (hasCard) => emit(
                    FacebookSuccess(
                      user: user,
                      needsAccountSetup: false,
                      needsAddCard: !hasCard,
                    ),
                  ),
                );
              } else {
                emit(FacebookSuccess(user: user, needsAccountSetup: true));
              }
            },
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
