part of 'splash_cubit.dart';

@immutable
sealed class SplashState {}

final class SplashInitial extends SplashState {}
final class SplashNavigateToOnboarding extends SplashState {}
final class SplashNavigateToHome extends SplashState {}
