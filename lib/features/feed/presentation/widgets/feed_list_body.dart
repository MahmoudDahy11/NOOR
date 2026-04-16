import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../cubit/feed_cubit.dart';
import 'feed_empty_state.dart';
import 'feed_room_card.dart';

class FeedListBody extends StatelessWidget {
  final FeedLoaded state;
  final String? joiningId;

  const FeedListBody({super.key, required this.state, this.joiningId});

  @override
  Widget build(BuildContext context) {
    if (state.rooms.isEmpty) {
      return FeedEmptyState(tab: state.activeTab);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          context.read<FeedCubit>().loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: state.rooms.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == state.rooms.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(
                  color: AppColors.primary)),
            );
          }
          final room = state.rooms[i];
          return FeedRoomCard(
            room: room,
            isJoining: joiningId == room.id,
            onJoin: () => context.read<FeedCubit>().joinRoom(room.id),
          );
        },
      ),
    );
  }
}

class FeedErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const FeedErrorBody({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded,
          color: AppColors.error, size: 48),
      const SizedBox(height: 16),
      Text(message, textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white),
        child: const Text('Retry'),
      ),
    ]),
  );
}
