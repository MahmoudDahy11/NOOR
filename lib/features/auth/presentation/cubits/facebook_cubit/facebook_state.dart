part of 'facebook_cubit.dart';


/* 
 * FacebookState class
 * base state class for FacebookCubit
 * uses Equatable for value comparison
 * has subclasses for initial, loading, success, and failure states
 */
sealed class FacebookState extends Equatable {
  const FacebookState();

  @override
  List<Object?> get props => [];
}

final class FacebookInitial extends FacebookState {}

final class FacebookLoading extends FacebookState {}

final class FacebookSuccess extends FacebookState {
  final UserEntity user;
  final bool needsAccountSetup;
  const FacebookSuccess({required this.user, this.needsAccountSetup = false});

  @override
  List<Object?> get props => [user, needsAccountSetup];
}

final class FacebookFailure extends FacebookState {
  final String errMessage;
  const FacebookFailure({required this.errMessage});

  @override
  List<Object?> get props => [errMessage];
}
