import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/live_room_cubit.dart';
import 'interaction_bar.dart';
import 'live_count_ring.dart';
import 'live_room_app_bar.dart';
import 'live_room_background.dart';
import 'personal_progress_card.dart';

class LiveRoomLoadedView extends StatelessWidget {
  const LiveRoomLoadedView({
    super.key,
    required this.state,
    required this.confettiCtrl,
  });

  final LiveRoomLoaded state;
  final ConfettiController confettiCtrl;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LiveRoomCubit>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F14),
      body: Stack(
        children: [
          const Positioned.fill(child: LiveRoomBackground()),
          SafeArea(
            child: Column(
              children: [
                LiveRoomAppBar(state: state, cubit: cubit),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: state.activeMode == InteractionMode.touch
                        ? cubit.increment
                        : null,
                    child: LiveCountRing(
                      totalCount: state.totalCount,
                      goal: state.room.goal,
                      isActive: state.room.isActive,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: PersonalProgressCard(
                    dhikr: state.room.dhikr,
                    personalCount: state.personalCount,
                    goal: state.room.goal,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: InteractionBar(
                    activeMode: state.activeMode,
                    isFreeRoom: state.room.isFree,
                    onModeChanged: cubit.setMode,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(confettiController: confettiCtrl),
          ),
        ],
      ),
    );
  }
}
