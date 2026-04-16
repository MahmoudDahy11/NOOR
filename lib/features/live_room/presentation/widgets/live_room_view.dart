import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/live_room_cubit.dart';
import 'live_room_loaded_view.dart';
import 'live_room_status_views.dart';

class LiveRoomView extends StatefulWidget {
  const LiveRoomView({super.key});

  @override
  State<LiveRoomView> createState() => _LiveRoomViewState();
}

class _LiveRoomViewState extends State<LiveRoomView> {
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
      builder: (context, state) => switch (state) {
        LiveRoomInitial() || LiveRoomLoading() => const LoadingView(),
        LiveRoomError(:final message) => ErrorView(message: message),
        LiveRoomLeft() => const SizedBox.shrink(),
        LiveRoomLoaded() => LiveRoomLoadedView(
          state: state,
          confettiCtrl: _confettiCtrl,
        ),
      },
    );
  }

  void _handleStateChange(BuildContext context, LiveRoomState state) {
    if (state is LiveRoomLoaded && state.goalReached && !_hasCelebrated) {
      _hasCelebrated = true;
      _confettiCtrl.play();
      showSnakBar(context, 'Goal reached! MashaAllah!');
    }
    if (state is LiveRoomLeft) context.goNamed(AppRouter.homeRoute);
    if (state is LiveRoomError) {
      showSnakBar(context, state.message, isError: true);
    }
  }
}
