import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/features/auth/presentation/pages/signin_page.dart';
import 'package:tally_islamic/features/auth/presentation/pages/signup_page.dart';

import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const resetPassword = '/reset-password';
  static const otp = '/otp';
  static const signin = '/signin';
  static const signup = '/signup';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: onboarding,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const OnboardingScreen()),
      ),
      // Auth route — will be added in next feature
      GoRoute(
        path: signin,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child:const SigninPage()
        ),
      ),
      GoRoute(path: resetPassword, builder: (context, state) => const ResetPasswordPage()),
      GoRoute(path: otp, builder: (context, state) => const OtpPage()),
      GoRoute(path: signup, builder: (context, state) => const SignupPage()),
    ],
  );

  static CustomTransitionPage _fadePage({
    required GoRouterState state,
    required Widget child,
  }) => CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 600),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );

  static CustomTransitionPage _slidePage({
    required GoRouterState state,
    required Widget child,
  }) => CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}
