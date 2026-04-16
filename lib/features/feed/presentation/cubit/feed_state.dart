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

final class FeedFailure extends FeedState {
  final String message;
  const FeedFailure(this.message);
}
