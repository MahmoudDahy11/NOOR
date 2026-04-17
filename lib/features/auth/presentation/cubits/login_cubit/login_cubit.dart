import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../account_setup/domain/repositories/account_setup_repo.dart';
import '../../../../add_card/domain/repo/add_card_repo.dart';
import '../../../domain/entity/user_entity.dart';
import '../../../domain/repo/auth_repo.dart';

part 'login_state.dart';

/*
 * LoginCubit class
 * extends Cubit with LoginState
 * manages the state for email/password login
 * uses FirebaseAuthRepo for authentication operations
 * emits loading, success, and failure states based on the login process
 */
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._firebaseAuthrepo, this._accountSetupRepo, this._addCardRepo)
    : super(LoginInitial());

  final FirebaseAuthRepo _firebaseAuthrepo;
  final AccountSetupRepo _accountSetupRepo;
  final AddCardRepo _addCardRepo;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (isClosed) return;
      emit(LoginLoading());

      final result = await _firebaseAuthrepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (isClosed) return;

      await result.fold(
        (failure) async => emit(LoginFailure(errMessage: failure.errMessage)),
        (user) async {
          final profileResult = await _accountSetupRepo.hasUserProfile(
            user.uId,
          );
          await profileResult.fold(
            (failure) async =>
                emit(LoginSuccess(user, needsAccountSetup: true)),
            (exists) async {
              if (exists) {
                final cardResult = await _addCardRepo.hasCard(user.uId);
                cardResult.fold(
                  (failure) => emit(
                    LoginSuccess(
                      user,
                      needsAccountSetup: false,
                      needsAddCard: true,
                    ),
                  ),
                  (hasCard) => emit(
                    LoginSuccess(
                      user,
                      needsAccountSetup: false,
                      needsAddCard: !hasCard,
                    ),
                  ),
                );
              } else {
                emit(LoginSuccess(user, needsAccountSetup: true));
              }
            },
          );
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(LoginFailure(errMessage: e.toString()));
      }
    }
  }
}
