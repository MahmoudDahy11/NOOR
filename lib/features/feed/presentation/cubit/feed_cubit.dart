import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/feed_room_entity.dart';
import '../../domain/repositories/feed_repo.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final FeedRepo _repo;

  FeedCubit({required FeedRepo repo})
    : _repo = repo,
      super(const FeedInitial());

  String _currentTab = 'active';

  Future<void> loadFeed({String tab = 'active'}) async {
    _currentTab = tab;
    emit(const FeedLoading());

    final result = await _repo.getRooms(status: tab);
    result.fold(
      (f) => emit(FeedFailure(f.errMessage, activeTab: tab)),
      (rooms) => emit(
        FeedLoaded(rooms: rooms, activeTab: tab, hasMore: rooms.length == 10),
      ),
    );
  }

  Future<void> switchTab(String tab) async {
    if (_currentTab == tab) return;
    await loadFeed(tab: tab);
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! FeedLoaded || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final lastRoom = current.rooms.last;

    final result = await _repo.getRooms(
      status: _currentTab,
      lastRoom: lastRoom,
    );

    result.fold(
      (f) => emit(FeedFailure(f.errMessage, activeTab: _currentTab)),
      (more) => emit(
        current.copyWith(
          rooms: [...current.rooms, ...more],
          hasMore: more.length == 10,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> joinRoom(String roomId) async {
    final current = state;
    if (current is! FeedLoaded) return;

    emit(
      FeedJoining(
        rooms: current.rooms,
        activeTab: current.activeTab,
        joiningRoomId: roomId,
      ),
    );

    log('[Feed] Joining room: $roomId');
    final result = await _repo.joinRoom(roomId);

    result.fold(
      (f) {
        log('[Feed] Join failed: ${f.errMessage}');
        emit(FeedFailure(f.errMessage, activeTab: current.activeTab));
      },
      (_) {
        log('[Feed] Join success: $roomId');
        emit(FeedJoinSuccess(roomId));
      },
    );
  }

  Future<void> notifyMe(String roomId) async {
    final current = state;
    if (current is! FeedLoaded) return;

    emit(
      FeedNotifying(
        rooms: current.rooms,
        activeTab: current.activeTab,
        notifyingRoomId: roomId,
      ),
    );

    final result = await _repo.notifyMe(roomId);
    result.fold(
      (f) => emit(FeedFailure(f.errMessage, activeTab: current.activeTab)),
      (_) => emit(
        FeedNotifyMeSuccess(
          roomId: roomId,
          rooms: current.rooms,
          activeTab: current.activeTab,
        ),
      ),
    );
  }

  Future<void> joinPrivateRoom(String roomId) async {
    log('[Feed] Joining private room: $roomId');
    final result = await _repo.getRoomById(roomId);

    result.fold(
      (f) => emit(FeedFailure(f.errMessage, activeTab: _currentTab)),
      (room) {
        if (!room.isActive) {
          emit(FeedFailure('Room is not active yet.', activeTab: _currentTab));
          return;
        }
        if (room.isExpired) {
          emit(FeedFailure('Room has expired.', activeTab: _currentTab));
          return;
        }
        joinRoom(roomId);
      },
    );
  }
}
