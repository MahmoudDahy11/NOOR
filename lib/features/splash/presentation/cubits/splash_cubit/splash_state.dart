part of 'splash_cubit.dart';

/*
 * SplashState class
 * base state class for SplashCubit
 * has subclasses for initial, loading, and navigation states
 */

@immutable
sealed class SplashState {}

final class SplashInitial extends SplashState {}

final class SplashLoading extends SplashState {}

final class NavigateToHome extends SplashState {}

final class NavigateToAccountSetup extends SplashState {}

final class NavigateToOnboarding extends SplashState {}

final class SplashError extends SplashState {
  final String message;

  SplashError({required this.message});
}
