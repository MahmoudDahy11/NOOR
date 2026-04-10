import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../../../account_setup/domain/repositories/account_setup_repo.dart';
import '../../../../auth/data/service/local_storage.dart';

part './splash_state.dart';

/*
 * SplashCubit class
 * extends Cubit with SplashState
 * manages the initialization and navigation logic for the splash screen
 * checks authentication status and profile completion
 * emits appropriate navigation states based on user status
 */
class SplashCubit extends Cubit<SplashState> {
  final AccountSetupRepo _accountSetupRepo;

  SplashCubit({required AccountSetupRepo accountSetupRepo})
      : _accountSetupRepo = accountSetupRepo,
        super(SplashInitial());

  Future<void> initializeApp() async {
    log("SplashCubit: Initialization started...");

    try {
      emit(SplashLoading());

      // Wait for a minimum time for the logo to appear
      await Future.delayed(const Duration(seconds: 2));

      log("SplashCubit: Checking auth status...");
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = LocalStorageService.isLoggedIn();

      // Navigation logkwic:
      // - If user is authenticated -> check if profile exists in Firestore
      // - If profile exists -> emit NavigateToHome
      // - If profile doesn't exist -> emit NavigateToAccountSetup
      // - If not authenticated -> emit NavigateToOnboarding
      if (loggedIn && user != null) {
        final result = await _accountSetupRepo.hasUserProfile(user.uid);

        result.fold(
          (failure) {
            log("SplashCubit: Error checking profile: ${failure.errMessage}");
            // If there's an error, navigate to account setup as fallback
            emit(NavigateToAccountSetup());
          },
          (profileExists) {
            if (profileExists) {
              log("SplashCubit: User authenticated with complete profile. Emitting NavigateToHome");
              emit(NavigateToHome());
            } else {
              log("SplashCubit: User authenticated but profile incomplete. Emitting NavigateToAccountSetup");
              emit(NavigateToAccountSetup());
            }
          },
        );
      } else {
        log("SplashCubit: User not authenticated. Emitting NavigateToOnboarding");
        emit(NavigateToOnboarding());
      }
    } catch (e, stack) {
      log("SplashCubit Error: $e");
      log("Stack Trace: $stack");
      // Fallback in case of error
      emit(SplashError(message: e.toString()));
    }
  }
}
