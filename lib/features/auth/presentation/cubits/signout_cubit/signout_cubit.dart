import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import '../../../domain/repo/auth_repo.dart';

part 'signout_state.dart';

/*
 * SignoutCubit class
 * extends Cubit with SignoutState
 * manages the state for user sign-out
 * uses FirebaseAuthRepo for authentication operations
 * emits loading, success, and failure states based on the sign-out process
 */
class SignoutCubit extends Cubit<SignoutState> {
  SignoutCubit(this._firebaseAuthrepo) : super(SignOutInitial());

  final FirebaseAuthRepo _firebaseAuthrepo;

  Future<void> signOut() async {
    if (isClosed) return;
    emit(SignOutLoading());
    if (isClosed) return;
    final result = await _firebaseAuthrepo.signOut();
    result.fold(
      (failure) => emit(SignOutFailure(errMessage: failure.errMessage)),
      (_) async {
          GetIt.I.reset();
        emit(SignOutSuccess());
      },
    );
  }

  void resetState() {
    emit(SignOutInitial());
  }
}
