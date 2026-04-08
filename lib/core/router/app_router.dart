import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const auth = '/auth';

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
        path: auth,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const Scaffold(
            body: Center(child: Text('Auth — Coming Soon')),
          ),
        ),
      ),
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
