import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/account_setup/domain/entities/user_profile_entity.dart';
import '../../features/account_setup/presentation/screens/account_setup_screen.dart';
import '../../features/add_card/presentation/screen/add_card_screen.dart';
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
import '../../features/home/home.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/views/edit_profile_screen.dart';
import '../../features/profile/presentation/views/profile_screen.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/settings/presentation/views/settings_screen.dart';
import '../../features/splash/presentation/views/splash_screen.dart';
import '../di/service_locator.dart';

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
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<LoginCubit>()),
            BlocProvider(create: (context) => getIt<GoogleCubit>()),
            BlocProvider(create: (context) => getIt<FacebookCubit>()),
          ],
          child: const SigninPage(),
        ),
      ),
      GoRoute(
        name: signupRoute,
        path: '/$signupRoute',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<SignupCubit>()),
            BlocProvider(create: (context) => getIt<GoogleCubit>()),
            BlocProvider(create: (context) => getIt<FacebookCubit>()),
          ],
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        name: otpRoute,
        path: '/$otpRoute',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<OtpCubit>(),
          child: const OtpPage(),
        ),
      ),
      GoRoute(
        name: resetPasswordRoute,
        path: '/$resetPasswordRoute',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<ForgetPasswordCubit>(),
          child: const ResetPasswordPage(),
        ),
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
              final profile = state.extra as UserProfileEntity;
              return _slidePage(
                state: state,
                child: BlocProvider.value(
                  value: getIt<ProfileCubit>(),
                  child: EditProfileScreen(profile: profile),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: settingsRoute,
        path: settingsRoute,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BlocProvider(
            create: (context) => getIt<SettingsCubit>(),
            child: const SettingsScreen(),
          ),
        ),
      ),
      GoRoute(
        name: addCardRoute,
        path: addCardRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const AddCardScreen()),
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
