import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/repo/auth_repo.dart';

part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit(this._firebaseAuthrepo) : super(ForgetPasswordInitial());
  final FirebaseAuthRepo _firebaseAuthrepo;

  Future<void> sendResetLink(String email) async {
    emit(ForgetPasswordLoading());
    if (isClosed) return;
    final result = await _firebaseAuthrepo.sendPasswordResetEmail(email);
    result.fold(
      (failure) => emit(ForgetPasswordFailure(errMessage: failure.errMessage)),
      (_) => emit(
        const ForgetPasswordSuccess(
          message: 'Check your inbox for the reset link',
        ),
      ),
    );
  }
}
