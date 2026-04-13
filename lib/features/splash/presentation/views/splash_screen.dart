import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repos/splash_repo.dart';
import '../cubits/splash_cubit/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SplashCubit(splashRepo: getIt<SplashRepo>())..initializeApp(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  void _handleNavigation(BuildContext context, SplashState state) {
    if (state is NavigateToHome) {
      log("Splash: Navigating to Home");
      context.goNamed(AppRouter.homeRoute);
    } else if (state is NavigateToAccountSetup) {
      log("Splash: Navigating to Account Setup");
      context.goNamed(AppRouter.accountSetupRoute);
    } else if (state is NavigateToAddCard) {
      log("Splash: Navigating to Add Card");
      context.goNamed(AppRouter.addCardRoute);
    } else if (state is NavigateToOnboarding) {
      log("Splash: Navigating to Onboarding");
      context.goNamed(AppRouter.onboardingRoute);
    } else if (state is SplashError) {
      log("Splash: Error occurred - ${state.message}. Navigating to Onboarding");
      context.goNamed(AppRouter.onboardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: _handleNavigation,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: SvgPicture.asset(
            AppAssets.splashLogo,
            width: 150,
          ),
        ),
      ),
    );
  }
}
