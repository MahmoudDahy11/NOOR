import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (e) {
      log('Firebase Auth not available: $e');
    }

    if (user != null && seenOnboarding) {
      emit(SplashNavigateToHome());
    } else {
      emit(SplashNavigateToOnboarding());
    }
  }
}
