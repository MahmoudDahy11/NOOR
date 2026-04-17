import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/router/app_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../notifications/domain/repositories/notification_repo.dart';
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

  NotificationRepo get _notificationRepo => getIt<NotificationRepo>();

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
      context.read<FeedCubit>().loadFeed(tab: state.activeTab);
    } else if (state is FeedNotifyMeSuccess) {
      showSnakBar(context, 'We’ll notify you when the room starts.');
    }
  }

  String _currentTab(FeedState state) => switch (state) {
    FeedLoaded(:final activeTab) => activeTab,
    FeedJoining(:final activeTab) => activeTab,
    FeedNotifying(:final activeTab) => activeTab,
    FeedNotifyMeSuccess(:final activeTab) => activeTab,
    _ => 'active',
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedCubit, FeedState>(
      listener: _handleState,
      builder: (context, state) => StreamBuilder<int>(
        stream: _notificationRepo.watchUnreadCount(),
        initialData: 0,
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;

          return Scaffold(
            backgroundColor: const Color(0xFF0A1F14),
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Compute horizontal padding to constrain feed width gracefully to 700px on ultra-wide screens
                final double hzPadding = constraints.maxWidth > 700
                    ? (constraints.maxWidth - 700) / 2
                    : 0;

                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                      context.read<FeedCubit>().loadMore();
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: hzPadding),
                        sliver: SliverToBoxAdapter(
                          child: FeedHeader(
                            unreadCount: unreadCount,
                            onNotificationTap: () {
                              context.pushNamed(AppRouter.notificationsRoute);
                            },
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: hzPadding),
                        sliver: SliverToBoxAdapter(
                          child: FeedTabBar(
                            activeTab: _currentTab(state),
                            onTabChanged: (t) =>
                                context.read<FeedCubit>().switchTab(t),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: hzPadding),
                        sliver: _buildBody(context, state),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
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
      FeedNotifying() => FeedListBody(
        state: FeedLoaded(rooms: state.rooms, activeTab: state.activeTab),
        joiningId: state.notifyingRoomId,
      ),
      FeedNotifyMeSuccess() => FeedListBody(
        state: FeedLoaded(rooms: state.rooms, activeTab: state.activeTab),
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
