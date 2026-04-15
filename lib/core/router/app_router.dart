import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/features/live_room/live.dart';
import '../../features/account_setup/presentation/screens/account_setup_screen.dart';
import '../../features/add_card/presentation/screen/add_card_screen.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/home.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screen/edit_profile_screen.dart';
import '../../features/profile/presentation/screen/profile_screen.dart';
import '../../features/settings/presentation/views/settings_screen.dart';
import '../../features/splash/presentation/views/splash_screen.dart';

class AppRouter {
  AppRouter._();

  // Route paths
  static const String splashRoute = '/';
  static const String onboardingRoute = 'onboarding';
  static const String signinRoute = 'signin';
  static const String signupRoute = 'signup';
  static const String otpRoute = 'otp';
  static const String resetPasswordRoute = 'reset-password';
  static const String accountSetupRoute = '/account-setup';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = 'edit-profile';
  static const String settingsRoute = '/settings';
  static const String addCardRoute = '/add-card';
  static const String liveRoomRoute = '/live-room';

  static final router = GoRouter(
    initialLocation: splashRoute,
    routes: [
      GoRoute(
        name: splashRoute,
        path: splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: onboardingRoute,
        path: '/$onboardingRoute',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: signinRoute,
        path: '/$signinRoute',
        builder: (context, state) => const SigninPage(),
      ),
      GoRoute(
        name: signupRoute,
        path: '/$signupRoute',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        name: otpRoute,
        path: '/$otpRoute',
        builder: (context, state) => const OtpPage(),
      ),
      GoRoute(
        name: resetPasswordRoute,
        path: '/$resetPasswordRoute',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        name: accountSetupRoute,
        path: accountSetupRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const AccountSetupScreen()),
      ),
      GoRoute(
        name: homeRoute,
        path: homeRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const Home()),
      ),
      GoRoute(
        name: profileRoute,
        path: profileRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const ProfileScreen()),
        routes: [
          GoRoute(
            name: editProfileRoute,
            path: editProfileRoute,
            pageBuilder: (context, state) {
              return _slidePage(state: state, child: const EditProfileScreen());
            },
          ),
        ],
      ),
      GoRoute(
        name: settingsRoute,
        path: settingsRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const SettingsScreen()),
      ),
      GoRoute(
        name: addCardRoute,
        path: addCardRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const AddCardScreen()),
      ),
      GoRoute(
        name: liveRoomRoute,
        path: liveRoomRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const LiveRoomScreen()),
      ),
    ],
  );

  static Page _slidePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeIn)),
          ),
          child: child,
        );
      },
    );
  }
}
