import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../auth/data/service/local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleInitialization();
  }

  Future<void> _handleInitialization() async {
    log("Splash: Initialization started...");

    try {
      // 1. Wait for a minimum time for the logo to appear
      await Future.delayed(const Duration(seconds: 2));

      log("Splash: Checking auth status...");
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = LocalStorageService.isLoggedIn();

      if (!mounted) return;
      if (loggedIn && user != null) {
        log("Splash: Navigating to Signin");
        context.goNamed(AppRouter.signinRoute);
      } else {
        log("Splash: Navigating to Onboarding");
        context.goNamed(AppRouter.onboardingRoute);
      }
    } catch (e, stack) {
      log("Splash Error: $e");
      log("Stack Trace: $stack");
      // Fallback in case of error
      if (mounted) context.goNamed(AppRouter.onboardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SvgPicture.asset(
          AppAssets.splashLogo,
          width: 150, // Ensure it's visible
        ),
      ),
    );
  }
}
