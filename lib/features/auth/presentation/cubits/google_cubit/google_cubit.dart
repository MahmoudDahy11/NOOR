import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  GoogleCubit(this.firebaseAuthrepo) : super(GoogleInitial());
  final FirebaseAuthRepo firebaseAuthrepo;
  Future<void> signInWithGoogle() async {
    try {
      if (isClosed) return;
      emit(GoogleLoading());
      if (isClosed) return;
      final result = await firebaseAuthrepo.signInWithGoogle();
      result.fold(
        (failure) => emit(GoogleFailure(errMessage: failure.errMessage)),
        (user) => emit(GoogleSuccess()),
      );
    } catch (e) {
      emit(GoogleFailure(errMessage: e.toString()));
    }
  }
}
