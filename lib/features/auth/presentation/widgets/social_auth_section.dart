import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubits/facebook_cubit/facebook_cubit.dart';
import '../cubits/google_cubit/google_cubit.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Or continue with"),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        MultiBlocListener(
          listeners: [
            BlocListener<GoogleCubit, GoogleState>(
              listener: (context, state) {
                if (state is GoogleSuccess) {
                  if (state.needsAccountSetup) {
                    context.goNamed(AppRouter.accountSetupRoute);
                  } else {
                    context.goNamed(AppRouter.homeRoute);
                  }
                } else if (state is GoogleFailure) {
                  showSnakBar(context, state.errMessage, isError: true);
                }
              },
            ),
            BlocListener<FacebookCubit, FacebookState>(
              listener: (context, state) {
                if (state is FacebookSuccess) {
                  log("Facebook login successful");
                  showSnakBar(context, "Facebook login successful");
                  if (state.needsAccountSetup) {
                    log("needsAccountSetup");
                    context.goNamed(AppRouter.accountSetupRoute);
                  } else {
                    context.goNamed(AppRouter.homeRoute);
                  }
                } else if (state is FacebookFailure) {
                  showSnakBar(context, state.errMessage, isError: true);
                  log("Facebook login failed: ${state.errMessage}");
                }
              },
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialIcon(
                AppAssets.googleIcon,
                () => context.read<GoogleCubit>().signInWithGoogle(),
              ),
              _socialIcon(
                AppAssets.facebookIcon,
                () => context.read<FacebookCubit>().signInWithFacebook(),
              ),
              _socialIcon(AppAssets.appleIcon, () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialIcon(String path, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.background),
        ),
        child: Image.asset(path, height: 24, width: 24),
      ),
    );
  }
}
