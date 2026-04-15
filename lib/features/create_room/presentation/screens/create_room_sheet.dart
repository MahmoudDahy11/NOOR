import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      Navigator.pop(context);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: false,
        builder: (_) => RoomCreatedSheet(
          room: state.room,
          onStartNow: () {
            Navigator.pop(context);
            context.read<CreateRoomCubit>().startRoom(state.room.id);
          },
          onLater: () => Navigator.pop(context),
        ),
      );
    } else if (state is RoomStarted) {
      // TODO: navigate to live room

      showSnakBar(context, 'Room started! 🕌');
      log('Room started! ${state.roomId}');
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
