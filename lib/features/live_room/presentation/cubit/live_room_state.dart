part of 'live_room_cubit.dart';

/// The four interaction modes available in a Live Room.
enum InteractionMode { touch, volume, remote, shake }

@immutable
sealed class LiveRoomState {
  const LiveRoomState();
}

final class LiveRoomInitial extends LiveRoomState {}

final class LiveRoomLoading extends LiveRoomState {}

final class LiveRoomLoaded extends LiveRoomState {
  final LiveRoomEntity room;
  final int totalCount;
  final int personalCount;
  final InteractionMode activeMode;
  final bool goalReached;
  final bool isAdmin;
  final Duration remainingTime;

  const LiveRoomLoaded({
    required this.room,
    required this.totalCount,
    required this.personalCount,
    required this.activeMode,
    required this.goalReached,
    required this.isAdmin,
    this.remainingTime = Duration.zero,
  });

  LiveRoomLoaded copyWith({
    LiveRoomEntity? room,
    int? totalCount,
    int? personalCount,
    InteractionMode? activeMode,
    bool? goalReached,
    bool? isAdmin,
    Duration? remainingTime,
  }) {
    return LiveRoomLoaded(
      room: room ?? this.room,
      totalCount: totalCount ?? this.totalCount,
      personalCount: personalCount ?? this.personalCount,
      activeMode: activeMode ?? this.activeMode,
      goalReached: goalReached ?? this.goalReached,
      isAdmin: isAdmin ?? this.isAdmin,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}

final class LiveRoomError extends LiveRoomState {
  final String message;
  const LiveRoomError(this.message);
}

final class LiveRoomLeft extends LiveRoomState {}
