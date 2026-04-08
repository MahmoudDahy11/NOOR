import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/repo/auth_repo.dart';

part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit(this._firebaseAuthrepo) : super(ForgetPasswordInitial());
  final FirebaseAuthRepo _firebaseAuthrepo;

  Future<void> resetPassword(String newPassword) async {
    emit(ForgetPasswordLoading());
    final result = await _firebaseAuthrepo.forgetPassword(
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(ForgetPasswordFailure(errMessage: failure.errMessage)),
      (_) => emit(const ForgetPasswordSuccess(message: 'تم تغيير كلمة المرور بنجاح')),
    );
  }
}
