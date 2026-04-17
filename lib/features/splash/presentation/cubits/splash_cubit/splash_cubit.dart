import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/repos/splash_repo.dart';

part 'splash_state.dart';

/*
 * SplashCubit class
 * extends Cubit with SplashState
 * manages the initialization and navigation logic for the splash screen
 * uses SplashRepo to determine the initial navigation path
 * emits appropriate navigation states based on the repository's decision
 */
class SplashCubit extends Cubit<SplashState> {
  final SplashRepo _splashRepo;

  SplashCubit({required SplashRepo splashRepo})
    : _splashRepo = splashRepo,
      super(SplashInitial());

  Future<void> initializeApp() async {
    log("SplashCubit: Initialization started...");

    try {
      emit(SplashLoading());

      // Wait for a minimum time for the logo to appear
      await Future.delayed(const Duration(seconds: 2));

      log("SplashCubit: Checking initial navigation...");
      final result = await _splashRepo.checkInitialNavigation();

      result.fold(
        (failure) {
          log(
            "SplashCubit: Error determining navigation: ${failure.errMessage}",
          );
          emit(SplashError(message: failure.errMessage));
        },
        (navTarget) {
          log("SplashCubit: Navigation target determined: $navTarget");
          switch (navTarget) {
            case 'home':
              emit(NavigateToHome());
              break;
            case 'account_setup':
              emit(NavigateToAccountSetup());
              break;
            case 'add_card':
              emit(NavigateToAddCard());
              break;
            case 'onboarding':
            default:
              emit(NavigateToOnboarding());
              break;
          }
        },
      );
    } catch (e, stack) {
      log("SplashCubit Error: $e");
      log("Stack Trace: $stack");
      emit(SplashError(message: e.toString()));
    }
  }
}
