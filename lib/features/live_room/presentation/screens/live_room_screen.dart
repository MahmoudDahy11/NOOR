import 'dart:developer';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/repositories/live_room_repo.dart';
import '../cubit/live_room_cubit.dart';
import '../widgets/interaction_bar.dart';
import '../widgets/live_count_ring.dart';
import '../widgets/live_room_app_bar.dart';
import '../widgets/personal_progress_card.dart';

/// Entry point for the Live Room feature.
///
/// Receives the [roomId] from the router, provides [LiveRoomCubit],
/// and delegates rendering to [_LiveRoomView].
class LiveRoomScreen extends StatelessWidget {
  final String roomId;

  const LiveRoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LiveRoomCubit(repo: getIt<LiveRoomRepo>(), roomId: roomId)
            ..loadRoom(),
      child: const _LiveRoomView(),
    );
  }
}

// =============================================================================
// Main view (stateful for ConfettiController lifecycle)
// =============================================================================

class _LiveRoomView extends StatefulWidget {
  const _LiveRoomView();

  @override
  State<_LiveRoomView> createState() => _LiveRoomViewState();
}

class _LiveRoomViewState extends State<_LiveRoomView> {
  late final ConfettiController _confettiCtrl;
  bool _hasCelebrated = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveRoomCubit, LiveRoomState>(
      listener: _handleStateChange,
      builder: (context, state) {
        return switch (state) {
          LiveRoomInitial() || LiveRoomLoading() => const _LoadingView(),
          LiveRoomError(:final message) => _ErrorView(message: message),
          LiveRoomLeft() => const SizedBox.shrink(),
          LiveRoomLoaded() => _buildLoaded(context, state),
        };
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Listener — side-effects only
  // ---------------------------------------------------------------------------

  void _handleStateChange(BuildContext context, LiveRoomState state) {
    // Confetti celebration
    if (state is LiveRoomLoaded && state.goalReached && !_hasCelebrated) {
      _hasCelebrated = true;
      _confettiCtrl.play();
      showSnakBar(context, '🎉 Goal reached! MashaAllah!');
      log('Goal reached! MashaAllah!');
    }

    // Navigate home on leave
    if (state is LiveRoomLeft) {
      context.goNamed(AppRouter.homeRoute);
      log('LiveRoomLeft');
    }

    // Surface errors
    if (state is LiveRoomError) {
      showSnakBar(context, state.message, isError: true);
      log('LiveRoomError: ${state.message}');
    }
  }

  // ---------------------------------------------------------------------------
  // Main loaded UI
  // ---------------------------------------------------------------------------

  Widget _buildLoaded(BuildContext context, LiveRoomLoaded state) {
    final cubit = context.read<LiveRoomCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1F14),
      body: Stack(
        children: [
          // 1. Subtle dot-pattern background
          const Positioned.fill(child: _DotPatternBackground()),

          // 2. Main content
          SafeArea(
            child: Column(
              children: [
                // App bar
                LiveRoomAppBar(
                  roomName: state.room.name,
                  isAdmin: state.isAdmin,
                  onLeave: cubit.leaveRoom,
                  onReset: state.isAdmin ? cubit.resetCount : null,
                ),

                const SizedBox(height: 8),

                // Count ring — tappable in touch mode
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

                const SizedBox(height: 20),

                // Personal progress card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PersonalProgressCard(
                    dhikr: state.room.dhikr,
                    personalCount: state.personalCount,
                    goal: state.room.goal,
                  ),
                ),

                const SizedBox(height: 20),

                // Interaction bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InteractionBar(
                    activeMode: state.activeMode,
                    isFreeRoom: state.room.isFree,
                    onModeChanged: cubit.setMode,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // 3. Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              gravity: 0.15,
              emissionFrequency: 0.06,
              colors: const [
                Color(0xFFFFD700),
                Color(0xFF2E8B57),
                Color(0xFF4CAF50),
                Color(0xFFFFC107),
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Private helper widgets
// =============================================================================

/// Subtle dot grid drawn over the dark green background.
class _DotPatternBackground extends StatelessWidget {
  const _DotPatternBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotPainter(), child: const SizedBox.expand());
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF143D28).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    const spacing = 26.0;
    const radius = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Full-screen loading state.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A1F14),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
    );
  }
}

/// Full-screen error state with retry.
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F14),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF5350),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE8F5E9), fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.read<LiveRoomCubit>().loadRoom(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
