part of 'onboarding_cubit.dart';

@immutable
sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

final class OnboardingPageChanged extends OnboardingState {
  final int currentPage;

  const OnboardingPageChanged(this.currentPage);
}

final class OnboardingDone extends OnboardingState {
  const OnboardingDone();
}
