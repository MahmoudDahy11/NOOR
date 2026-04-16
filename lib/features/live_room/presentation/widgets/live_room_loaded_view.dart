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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return _buildWideLayout(cubit, constraints);
                      } else if (constraints.maxWidth > 500) {
                        return _buildTabletLayout(cubit, constraints);
                      }
                      return _buildNarrowLayout(cubit, constraints);
                    },
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

  Widget _buildNarrowLayout(LiveRoomCubit cubit, BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(flex: 3, child: _buildRing(cubit, 280)),
        _buildStatsBar(24, 20),
        _buildInteractionBar(24, 20, cubit),
      ],
    );
  }

  Widget _buildTabletLayout(LiveRoomCubit cubit, BoxConstraints constraints) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(height: 380, child: _buildRing(cubit, 380)),
              const SizedBox(height: 50),
              _buildStatsBar(24, 0),
              _buildInteractionBar(24, 40, cubit),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(LiveRoomCubit cubit, BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(flex: 1, child: Center(child: _buildRing(cubit, 420))),
        Expanded(
          flex: 1,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatsBar(24, 0),
                  const SizedBox(height: 40),
                  _buildInteractionBar(24, 0, cubit),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRing(LiveRoomCubit cubit, double size) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: state.activeMode == InteractionMode.touch ? cubit.increment : null,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: FittedBox(
            child: LiveCountRing(
              totalCount: state.totalCount,
              goal: state.room.goal,
              isActive: state.room.isActive,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(double hzPadding, double vtPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hzPadding, vertical: vtPadding),
      child: PersonalProgressCard(
        dhikr: state.room.dhikr,
        personalCount: state.personalCount,
        goal: state.room.goal,
      ),
    );
  }

  Widget _buildInteractionBar(
    double hzPadding,
    double vtPadding,
    LiveRoomCubit cubit,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hzPadding, vtPadding, hzPadding, 24),
      child: InteractionBar(
        activeMode: state.activeMode,
        isFreeRoom: state.room.isFree,
        onModeChanged: cubit.setMode,
      ),
    );
  }
}
