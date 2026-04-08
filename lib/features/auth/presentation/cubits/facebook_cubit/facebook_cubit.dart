import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
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
  final FirebaseAuthRepo authRepo;
  FacebookCubit(this.authRepo) : super(FacebookInitial());

  Future<void> signInWithFacebook() async {
    emit(FacebookLoading());
    final Either<CustomFailure, UserEntity> result = await authRepo
        .signinWithFacebook();

    result.fold(
      (failure) => emit(FacebookFailure(errMessage: failure.errMessage)),
      (user) => emit(FacebookSuccess(user: user)),
    );
  }
}
