part of 'feed_cubit.dart';

@immutable
sealed class FeedState {
  const FeedState();
}

final class FeedInitial extends FeedState {
  const FeedInitial();
}

final class FeedLoading extends FeedState {
  const FeedLoading();
}

final class FeedLoaded extends FeedState {
  final List<FeedRoomEntity> rooms;
  final String activeTab; // 'active' | 'pending'
  final bool hasMore;
  final bool isLoadingMore;

  const FeedLoaded({
    required this.rooms,
    required this.activeTab,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  FeedLoaded copyWith({
    List<FeedRoomEntity>? rooms,
    String? activeTab,
    bool? hasMore,
    bool? isLoadingMore,
  }) => FeedLoaded(
    rooms: rooms ?? this.rooms,
    activeTab: activeTab ?? this.activeTab,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

final class FeedJoining extends FeedState {
  final List<FeedRoomEntity> rooms;
  final String activeTab;
  final String joiningRoomId;

  const FeedJoining({
    required this.rooms,
    required this.activeTab,
    required this.joiningRoomId,
  });
}

final class FeedJoinSuccess extends FeedState {
  final String roomId;
  const FeedJoinSuccess(this.roomId);
}

final class FeedNotifying extends FeedState {
  final List<FeedRoomEntity> rooms;
  final String activeTab;
  final String notifyingRoomId;

  const FeedNotifying({
    required this.rooms,
    required this.activeTab,
    required this.notifyingRoomId,
  });
}

final class FeedNotifyMeSuccess extends FeedState {
  final String roomId;
  final List<FeedRoomEntity> rooms;
  final String activeTab;

  const FeedNotifyMeSuccess({
    required this.roomId,
    required this.rooms,
    required this.activeTab,
  });
}

final class FeedFailure extends FeedState {
  final String message;
  final String activeTab;

  const FeedFailure(this.message, {this.activeTab = 'active'});
}
