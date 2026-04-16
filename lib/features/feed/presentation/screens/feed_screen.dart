import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/router/app_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../domain/repositories/feed_repo.dart';
import '../cubit/feed_cubit.dart';
import '../widgets/feed_header.dart';
import '../widgets/feed_list_body.dart';
import '../widgets/feed_tab_bar.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          FeedCubit(repo: getIt<FeedRepo>())..loadFeed(tab: 'active'),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  void _handleState(BuildContext context, FeedState state) {
    if (state is FeedJoinSuccess) {
      showSnakBar(context, 'Joined room! 🕌');
      context.goNamed(
        AppRouter.liveRoomRoute,
        pathParameters: {'roomId': state.roomId},
      );
    } else if (state is FeedFailure) {
      log('Feed Failure: ${state.message}');
      showSnakBar(context, state.message, isError: true);
      context.read<FeedCubit>().loadFeed();
    }
  }

  String _currentTab(FeedState state) => switch (state) {
    FeedLoaded(:final activeTab) => activeTab,
    FeedJoining(:final activeTab) => activeTab,
    _ => 'active',
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedCubit, FeedState>(
      listener: _handleState,
      builder: (context, state) => Scaffold(
        backgroundColor: const Color(0xFF0A1F14),
        body: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
              context.read<FeedCubit>().loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: FeedHeader()),
              SliverToBoxAdapter(
                child: FeedTabBar(
                  activeTab: _currentTab(state),
                  onTabChanged: (t) => context.read<FeedCubit>().switchTab(t),
                ),
              ),
              _buildBody(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FeedState state) {
    return switch (state) {
      FeedLoading() => const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      FeedLoaded() => FeedListBody(state: state),
      FeedJoining() => FeedListBody(
        state: FeedLoaded(rooms: state.rooms, activeTab: state.activeTab),
        joiningId: state.joiningRoomId,
      ),
      FeedFailure() => SliverFillRemaining(
        hasScrollBody: false,
        child: FeedErrorBody(
          message: state.message,
          onRetry: () => context.read<FeedCubit>().loadFeed(),
        ),
      ),
      _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
    };
  }
}
