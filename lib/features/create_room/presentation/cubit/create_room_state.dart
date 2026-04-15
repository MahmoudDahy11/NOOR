part of 'create_room_cubit.dart';

@immutable
sealed class CreateRoomState {
  const CreateRoomState();
}

final class CreateRoomInitial extends CreateRoomState {}

final class CreateRoomLoading extends CreateRoomState {}

final class CreateRoomSuccess extends CreateRoomState {
  final RoomEntity room;
  const CreateRoomSuccess(this.room);
}

final class CreateRoomFailure extends CreateRoomState {
  final String message;
  const CreateRoomFailure(this.message);
}

final class RoomStarting extends CreateRoomState {}

final class RoomStarted extends CreateRoomState {
  final String roomId;
  const RoomStarted(this.roomId);
}
