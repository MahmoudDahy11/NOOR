import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/profile_cubit.dart';
import 'profile_content.dart';
import 'profile_error_state.dart';
import 'profile_shimmer.dart';
import 'profile_sign_out_dialog.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.reactionId != current.reactionId,
        listener: _handleReaction,
        builder: (context, state) {
          if (state.isInitialLoading) return const ProfileShimmer();
          if (state.profile == null) {
            return ProfileErrorState(
              message: state.message ?? 'Failed to load profile.',
              onRetry: context.read<ProfileCubit>().getProfile,
            );
          }
          return ProfileContent(
            profile: state.profile!,
            isStartingRoom: state.isStartingRoom,
            onStartRoom: context.read<ProfileCubit>().startRoom,
            onEditProfile: () async {
              final result = await context.pushNamed<dynamic>(
                AppRouter.editProfileRoute,
              );
              if (result == true && context.mounted) {
                context.read<ProfileCubit>().getProfile();
              }
            },
            onOpenSettings: () => context.pushNamed(AppRouter.settingsRoute),
            onSignOut: () => showProfileSignOutDialog(context),
          );
        },
      ),
    );
  }

  void _handleReaction(BuildContext context, ProfileState state) {
    if (state.outcome == ProfileOutcome.roomStarted &&
        state.startedRoomId != null) {
      showSnakBar(context, 'Room started successfully!');
      context.goNamed(
        AppRouter.liveRoomRoute,
        pathParameters: {'roomId': state.startedRoomId!},
      );
    } else if (state.outcome == ProfileOutcome.signedOut) {
      context.goNamed(AppRouter.signinRoute);
    } else if (state.outcome == ProfileOutcome.error && state.message != null) {
      showSnakBar(context, state.message!, isError: true);
    }
  }
}
