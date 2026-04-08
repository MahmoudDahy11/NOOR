part of 'google_cubit.dart';


/*
 * GoogleState class
 * base state class for GoogleCubit
 * has subclasses for initial, loading, success, and failure states
 */
@immutable
sealed class GoogleState {}

final class GoogleInitial extends GoogleState {}

final class GoogleLoading extends GoogleState {}

final class GoogleSuccess extends GoogleState {}

final class GoogleFailure extends GoogleState {
  final String errMessage;

  GoogleFailure({required this.errMessage});
}
