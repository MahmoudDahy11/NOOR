import 'package:bloc/bloc.dart';

import 'package:meta/meta.dart';

import '../../../domain/entity/user_entity.dart';
import '../../../domain/repo/auth_repo.dart';

part '../login_cubit/login_state.dart';

/*
 * LoginCubit class
 * extends Cubit with LoginState
 * manages the state for email/password login
 * uses FirebaseAuthRepo for authentication operations
 * emits loading, success, and failure states based on the login process
 */
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._firebaseAuthrepo) : super(LoginInitial());

  final FirebaseAuthRepo _firebaseAuthrepo;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (isClosed) return;
      emit(LoginLoading());
      if (isClosed) return;
      final result = await _firebaseAuthrepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      result.fold(
        (failure) => emit(LoginFailure(errMessage: failure.errMessage)),
        (user) => emit(LoginSuccess(user)),
      );
    } catch (e) {
      emit(LoginFailure(errMessage: e.toString()));
    }
  }
}
