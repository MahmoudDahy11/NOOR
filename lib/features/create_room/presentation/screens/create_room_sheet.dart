import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/router/app_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/create_room_repo.dart';
import '../cubit/create_room_cubit.dart';
import '../widgets/create_room_form.dart';
import '../widgets/room_created_sheet.dart';

class CreateRoomSheet extends StatelessWidget {
  final RoomType roomType;

  const CreateRoomSheet({super.key, required this.roomType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateRoomCubit(repo: getIt<CreateRoomRepo>()),
      child: _CreateRoomSheetView(roomType: roomType),
    );
  }
}

class _CreateRoomSheetView extends StatelessWidget {
  final RoomType roomType;
  const _CreateRoomSheetView({required this.roomType});

  void _handleState(BuildContext context, CreateRoomState state) {
    if (state is CreateRoomSuccess) {
      final room = state.room;
      final repo = getIt<CreateRoomRepo>();

      // Capture navigator BEFORE popping — context is unmounted after pop.
      final navigator = Navigator.of(context);

      // Close the creation sheet
      navigator.pop();

      // Show success sheet using navigator.context (still valid).
      showModalBottomSheet(
        context: navigator.context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: false,
        builder: (sheetContext) => RoomCreatedSheet(
          room: room,
          onStartNow: () async {
            final result = await repo.startRoom(room.id);
            result.fold(
              (failure) {
                log('[Activation] Failed: ${failure.errMessage}');
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
              (_) {
                log('[Activation] Room started: ${room.id}');
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                // Navigate to the live room screen
                GoRouter.of(navigator.context).goNamed(
                  AppRouter.liveRoomRoute,
                  pathParameters: {'roomId': room.id},
                );
              },
            );
          },
          onLater: () => Navigator.of(sheetContext).pop(),
        ),
      );
    } else if (state is CreateRoomFailure) {
      showSnakBar(context, state.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateRoomCubit, CreateRoomState>(
      listener: _handleState,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: CreateRoomForm(
            roomType: roomType,
            onSubmit: (params) =>
                context.read<CreateRoomCubit>().createRoom(params),
          ),
        ),
      ),
    );
  }
}
