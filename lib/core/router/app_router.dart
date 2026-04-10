import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/features/home/home.dart';

import '../../core/di/service_locator.dart';
import '../../features/account_setup/presentation/cubit/account_setup_cubit.dart';
import '../../features/account_setup/presentation/screens/account_setup_screen.dart';
import '../../features/auth/presentation/cubits/facebook_cubit/facebook_cubit.dart';
import '../../features/auth/presentation/cubits/forget_password_cubit/forget_password_cubit.dart';
import '../../features/auth/presentation/cubits/google_cubit/google_cubit.dart';
import '../../features/auth/presentation/cubits/login_cubit/login_cubit.dart';
import '../../features/auth/presentation/cubits/otp_cubit/otp_cubit.dart';
import '../../features/auth/presentation/cubits/signup_cubit/signup_cubit.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
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

  static final router = GoRouter(
    initialLocation: splashRoute,
    routes: [
      GoRoute(
        path: splashRoute,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        name: onboardingRoute,
        path: '/$onboardingRoute',
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const OnboardingScreen()),
      ),
      GoRoute(
        name: signinRoute,
        path: '/$signinRoute',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<LoginCubit>()),
              BlocProvider(create: (_) => getIt<GoogleCubit>()),
              BlocProvider(create: (_) => getIt<FacebookCubit>()),
            ],
            child: const SigninPage(),
          ),
        ),
      ),
      GoRoute(
        name: signupRoute,
        path: '/$signupRoute',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<SignupCubit>()),
              BlocProvider(create: (_) => getIt<GoogleCubit>()),
              BlocProvider(create: (_) => getIt<FacebookCubit>()),
            ],
            child: const SignupPage(),
          ),
        ),
      ),
      GoRoute(
        name: otpRoute,
        path: '/$otpRoute',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BlocProvider(
            create: (_) => getIt<OtpCubit>(),
            child: const OtpPage(),
          ),
        ),
      ),
      GoRoute(
        name: resetPasswordRoute,
        path: '/$resetPasswordRoute',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BlocProvider(
            create: (_) => getIt<ForgetPasswordCubit>(),
            child: const ResetPasswordPage(),
          ),
        ),
      ),
      GoRoute(
        name: accountSetupRoute,
        path: '/$accountSetupRoute',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BlocProvider(
            create: (_) => getIt<AccountSetupCubit>(),
            child: const AccountSetupScreen(),
          ),
        ),
      ),
      GoRoute(
        name: homeRoute,
        path: '/$homeRoute',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const Home(),
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
