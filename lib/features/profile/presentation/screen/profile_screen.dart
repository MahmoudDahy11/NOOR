import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/interests_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu.dart';
import '../widgets/profile_shimmer.dart';
import '../widgets/profile_stats.dart';
import '../widgets/ticket_inventory_placeholder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..getProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSignOutSuccess) {
            context.goNamed(AppRouter.signinRoute);
          } else if (state is ProfileError) {
            showSnakBar(context, state.message , isError: true);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ProfileShimmer();
          } else if (state is ProfileSuccess) {
            final profile = state.profile;
            final currentUser = FirebaseAuth.instance.currentUser;
            // Use email if available, otherwise fallback or empty
            final userName = currentUser?.email ?? '';

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: ProfileHeader(
                        avatar: profile.user.avatarAsset,
                        name: profile.user.displayName,
                        userName: userName,
                        bio: profile.user.bio,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ProfileStats(
                      joined: profile.roomsJoined,
                      counts: profile.totalCounts,
                      created: profile.roomsCreated,
                    ),
                    const SizedBox(height: 30),
                    const TicketInventoryPlaceholder(),
                    const SizedBox(height: 30),
                    InterestsSection(interests: profile.user.interests),
                    const SizedBox(height: 30),
                    ProfileMenu(
                      onEditProfile: () async {
                        final result = await context.pushNamed<dynamic>(
                          AppRouter.editProfileRoute,
                        );
                        if (result == true && context.mounted) {
                          context.read<ProfileCubit>().getProfile();
                        }
                      },
                      onSettings: () {
                        context.pushNamed(AppRouter.settingsRoute);
                      },
                      onSignOut: () {
                        _showSignOutDialog(context);
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ProfileCubit>().signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
