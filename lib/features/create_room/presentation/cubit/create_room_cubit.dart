import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/create_room_params.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/create_room_repo.dart';

part 'create_room_state.dart';

class CreateRoomCubit extends Cubit<CreateRoomState> {
  final CreateRoomRepo _repo;

  CreateRoomCubit({required CreateRoomRepo repo})
    : _repo = repo,
      super(CreateRoomInitial());

  Future<void> createRoom(CreateRoomParams params) async {
    emit(CreateRoomLoading());

    log(
      '[CreateRoom] type=${params.type} dhikr=${params.dhikr} '
      'goal=${params.goal} duration=${params.durationHours}h '
      'tickets=${params.ticketsRequired} public=${params.isPublic}',
    );

    try {
      final result = await _repo.createRoom(params);
      result.fold(
        (failure) {
          log('[CreateRoom] Failed: ${failure.errMessage}');
          emit(CreateRoomFailure(failure.errMessage));
        },
        (room) {
          log('[CreateRoom] Success: ${room.id}');
          emit(CreateRoomSuccess(room));
        },
      );
    } catch (e) {
      log('[CreateRoom] Unexpected error: $e');
      emit(const CreateRoomFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> startRoom(String roomId) async {
    emit(RoomStarting());

    log('[CreateRoom] Starting room: $roomId');

    try {
      final result = await _repo.startRoom(roomId);

      result.fold(
        (failure) {
          log('[CreateRoom] Start failed: ${failure.errMessage}');
          emit(CreateRoomFailure(failure.errMessage));
        },
        (_) {
          log('[CreateRoom] Room started: $roomId');
          emit(RoomStarted(roomId));
        },
      );
    } catch (e) {
      log('[CreateRoom] Unexpected start error: $e');
      emit(const CreateRoomFailure('Failed to start room.'));
    }
  }
}
