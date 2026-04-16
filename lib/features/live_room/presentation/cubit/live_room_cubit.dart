import 'package:bloc/bloc.dart';

import '../../domain/repositories/live_room_repo.dart';
import 'live_room_runtime.dart';
import 'live_room_state.dart';

export 'live_room_state.dart';

class LiveRoomCubit extends Cubit<LiveRoomState> {
  LiveRoomCubit({required LiveRoomRepo repo, required this.roomId})
    : _repo = repo,
      _runtime = LiveRoomRuntime(repo: repo, roomId: roomId),
      super(LiveRoomInitial());

  final LiveRoomRepo _repo;
  final LiveRoomRuntime _runtime;
  final String roomId;

  Future<void> loadRoom() async {
    emit(LiveRoomLoading());
    final result = await _repo.getRoomDetails(roomId);
    result.fold((f) => emit(LiveRoomError(f.errMessage)), (room) {
      final remaining =
          room.expiresAt?.difference(DateTime.now()) ?? Duration.zero;
      _emitLoaded(
        LiveRoomLoaded(
          room: room,
          totalCount: 0,
          personalCount: 0,
          activeMode: InteractionMode.touch,
          goalReached: false,
          isAdmin: _repo.isCreator(room.creatorId),
          remainingTime: remaining.isNegative ? Duration.zero : remaining,
        ),
      );
      _runtime.bindCounters(_currentLoaded, _emitLoaded);
      _runtime.startCountdown(
        room.expiresAt,
        currentLoaded: _currentLoaded,
        emitLoaded: _emitLoaded,
        onExpire: (isAdmin) => isAdmin ? endRoom() : leaveRoom(),
      );
    });
  }

  Future<void> increment() async {
    if (!_runtime.canIncrement(state)) return;
    final result = await _repo.incrementCounter(roomId);
    result.fold((f) => emit(LiveRoomError(f.errMessage)), (_) {});
  }

  void setMode(InteractionMode mode) {
    final current = _currentLoaded();
    if (current == null) return;
    if (current.activeMode == InteractionMode.shake &&
        mode != InteractionMode.shake) {
      _runtime.stopShake();
    }
    _emitLoaded(current.copyWith(activeMode: mode));
    if (mode == InteractionMode.shake) _runtime.startShake(increment);
  }

  Future<void> resetCount() async =>
      _runAdminAction(_repo.resetCounter(roomId));
  Future<void> leaveRoom() async => _exit(_repo.leaveRoom(roomId));
  Future<void> endRoom() async =>
      _runAdminAction(_repo.endRoom(roomId), leaveOnSuccess: true);

  Future<void> _runAdminAction(
    Future<dynamic> action, {
    bool leaveOnSuccess = false,
  }) async {
    final current = _currentLoaded();
    if (current == null || !current.isAdmin) return;
    final result = await action;
    result.fold(
      (f) => emit(LiveRoomError(f.errMessage)),
      (_) => leaveOnSuccess ? emit(LiveRoomLeft()) : null,
    );
  }

  Future<void> _exit(Future<dynamic> action) async {
    _runtime.stopShake();
    final result = await action;
    result.fold(
      (f) => emit(LiveRoomError(f.errMessage)),
      (_) => emit(LiveRoomLeft()),
    );
  }

  LiveRoomLoaded? _currentLoaded() =>
      state is LiveRoomLoaded ? state as LiveRoomLoaded : null;
  void _emitLoaded(LiveRoomLoaded next) => emit(next);

  @override
  Future<void> close() {
    _runtime.dispose();
    return super.close();
  }
}
