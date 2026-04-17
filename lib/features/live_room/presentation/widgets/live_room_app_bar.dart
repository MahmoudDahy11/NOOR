import 'package:flutter/material.dart';
import 'package:tally_islamic/core/theme/app_colors.dart';

import '../cubit/live_room_cubit.dart';
import 'live_room_dialogs.dart';
import 'live_room_timer_chip.dart';

class LiveRoomAppBar extends StatelessWidget {
  const LiveRoomAppBar({super.key, required this.state, required this.cubit});

  final LiveRoomLoaded state;
  final LiveRoomCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Leave Room',
            onPressed: () => showLeaveRoomDialog(context, cubit.leaveRoom),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  state.room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8F5E9),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InfoChip(
                    label: 'ID: ${state.room.id}',
                    color: const Color(0xFFA5D6A7),
                    background: const Color(0xFF1B5E20),
                  ),
                  const SizedBox(width: 8),
                  LiveRoomTimerChip(remainingTime: state.remainingTime),
                ],
              ),
            ],
          ),
          const Spacer(),
          state.isAdmin
              ? LiveRoomMenu(cubit: cubit)
              : const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
