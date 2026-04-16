import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/repositories/live_room_repo.dart';
import '../cubit/live_room_cubit.dart';
import '../widgets/live_room_view.dart';

class LiveRoomScreen extends StatelessWidget {
  const LiveRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LiveRoomCubit(repo: getIt<LiveRoomRepo>(), roomId: roomId)
            ..loadRoom(),
      child: const LiveRoomView(),
    );
  }
}
