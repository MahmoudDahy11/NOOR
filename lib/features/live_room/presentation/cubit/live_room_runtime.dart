import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

import '../../domain/repositories/live_room_repo.dart';
import 'live_room_state.dart';

class LiveRoomRuntime {
  LiveRoomRuntime({required this.repo, required this.roomId});

  final LiveRoomRepo repo;
  final String roomId;
  StreamSubscription<int>? _totalSub;
  StreamSubscription<int>? _personalSub;
  StreamSubscription<AccelerometerEvent>? _shakeSub;
  Timer? _countdownTimer;
  DateTime _lastIncrement = DateTime(0), _lastShake = DateTime(0);

  static const tapGap = Duration(milliseconds: 80);
  static const shakeGap = Duration(milliseconds: 500);
  static const shakeThreshold = 225.0;

  bool canIncrement(LiveRoomState state) {
    final now = DateTime.now();
    if (state is! LiveRoomLoaded || now.difference(_lastIncrement) < tapGap) {
      return false;
    }
    _lastIncrement = now;
    return true;
  }

  void bindCounters(
    LiveRoomLoaded? Function() currentLoaded,
    void Function(LiveRoomLoaded next) emitLoaded,
  ) {
    _totalSub?.cancel();
    _personalSub?.cancel();
    _totalSub = repo.watchTotalCounter(roomId).listen((count) {
      final current = currentLoaded();
      if (current == null) return;
      emitLoaded(
        current.copyWith(
          totalCount: count,
          goalReached: current.room.goal > 0 && count >= current.room.goal,
        ),
      );
    });
    _personalSub = repo.watchPersonalCounter(roomId).listen((count) {
      final current = currentLoaded();
      if (current != null) emitLoaded(current.copyWith(personalCount: count));
    });
  }

  void startShake(Future<void> Function() onIncrement) {
    _shakeSub?.cancel();
    _shakeSub = accelerometerEventStream().listen((event) {
      final now = DateTime.now();
      final magnitude =
          event.x * event.x + event.y * event.y + event.z * event.z;
      if (magnitude <= shakeThreshold ||
          now.difference(_lastShake) <= shakeGap) {
        return;
      }
      _lastShake = now;
      onIncrement();
    });
  }

  void startCountdown(
    DateTime? expiresAt, {
    required LiveRoomLoaded? Function() currentLoaded,
    required void Function(LiveRoomLoaded next) emitLoaded,
    required Future<void> Function(bool isAdmin) onExpire,
  }) {
    _countdownTimer?.cancel();
    if (expiresAt == null) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final current = currentLoaded();
      if (current == null) {
        return;
      }
      final remaining = expiresAt.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        return onExpire(current.isAdmin);
      }
      emitLoaded(current.copyWith(remainingTime: remaining));
    });
  }

  void stopShake() {
    _shakeSub?.cancel();
    _shakeSub = null;
  }

  void dispose() {
    _totalSub?.cancel();
    _personalSub?.cancel();
    _shakeSub?.cancel();
    _countdownTimer?.cancel();
  }
}
