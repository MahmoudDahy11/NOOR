import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../domain/entities/live_room_entity.dart';
import '../../domain/repositories/live_room_repo.dart';

part 'live_room_state.dart';

/// Manages a single live-room session.
///
/// Responsibilities:
/// 1. Load room metadata from Firestore (one-shot).
/// 2. Subscribe to RTDB streams for `total` and `personal` counters.
/// 3. Relay each tap / shake / volume event as an atomic RTDB increment.
/// 4. Manage sensor subscriptions and dispose them cleanly.
class LiveRoomCubit extends Cubit<LiveRoomState> {
  final LiveRoomRepo _repo;
  final String roomId;

  // --- Stream subscriptions (cleaned up in close()) ---
  StreamSubscription<int>? _totalSub;
  StreamSubscription<int>? _personalSub;
  StreamSubscription<AccelerometerEvent>? _shakeSub;
  Timer? _countdownTimer;

  // --- Throttle: prevent rapid-fire RTDB writes ---
  DateTime _lastIncrement = DateTime(0);
  static const _incrementThrottle = Duration(milliseconds: 80);

  // --- Shake detection tuning ---
  DateTime _lastShakeTime = DateTime(0);
  static const _shakeThreshold = 15.0;
  static const _shakeCooldown = Duration(milliseconds: 500);

  LiveRoomCubit({required LiveRoomRepo repo, required this.roomId})
    : _repo = repo,
      super(LiveRoomInitial());

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches room metadata, then subscribes to RTDB counter streams.
  Future<void> loadRoom() async {
    emit(LiveRoomLoading());
    log('[LiveRoom] Loading room: $roomId');

    final result = await _repo.getRoomDetails(roomId);
    result.fold(
      (failure) {
        log('[LiveRoom] Load failed: ${failure.errMessage}');
        emit(LiveRoomError(failure.errMessage));
      },
      (room) {
        log('[LiveRoom] Room loaded: ${room.name}');
        final isAdmin = _repo.isCreator(room.creatorId);

        final remaining = room.expiresAt != null
            ? room.expiresAt!.difference(DateTime.now())
            : Duration.zero;

        emit(
          LiveRoomLoaded(
            room: room,
            totalCount: 0,
            personalCount: 0,
            activeMode: InteractionMode.touch,
            goalReached: false,
            isAdmin: isAdmin,
            remainingTime: remaining,
          ),
        );
        _startCounterStreams();
        _startCountdown(room.expiresAt);
      },
    );
  }

  /// Atomically increments BOTH `total` and `participants/{uid}` in RTDB.
  Future<void> increment() async {
    final now = DateTime.now();
    if (now.difference(_lastIncrement) < _incrementThrottle) return;
    _lastIncrement = now;

    HapticFeedback.mediumImpact();

    final result = await _repo.incrementCounter(roomId);
    result.fold(
      (f) => log('[LiveRoom] Increment failed: ${f.errMessage}'),
      (_) {},
    );
  }

  /// Switches the active interaction mode.
  ///
  /// Starts / stops the shake sensor subscription accordingly.
  void setMode(InteractionMode mode) {
    final current = state;
    if (current is! LiveRoomLoaded) return;

    // Tear down previous sensor if switching away
    if (current.activeMode == InteractionMode.shake &&
        mode != InteractionMode.shake) {
      _stopShakeListener();
    }

    emit(current.copyWith(activeMode: mode));

    // Bring up new sensor
    if (mode == InteractionMode.shake) {
      _startShakeListener();
    }

    log('[LiveRoom] Mode → ${mode.name}');
  }

  /// Resets the RTDB counter (admin-only guard).
  Future<void> resetCount() async {
    final current = state;
    if (current is! LiveRoomLoaded || !current.isAdmin) {
      log('[LiveRoom] Reset denied — not admin');
      return;
    }

    log('[LiveRoom] Resetting counters for room: $roomId');
    final result = await _repo.resetCounter(roomId);
    result.fold(
      (f) => log('[LiveRoom] Reset failed: ${f.errMessage}'),
      (_) => log('[LiveRoom] Counters reset'),
    );
  }

  /// Leaves the room (removes UID from Firestore participants).
  Future<void> leaveRoom() async {
    log('[LiveRoom] Leaving room: $roomId');
    _stopShakeListener();
    await _repo.leaveRoom(roomId);
    emit(LiveRoomLeft());
  }

  /// Ends the room for everyone (admin-only guard).
  Future<void> endRoom() async {
    final current = state;
    if (current is! LiveRoomLoaded || !current.isAdmin) {
      log('[LiveRoom] End denied — not admin');
      return;
    }

    log('[LiveRoom] Ending room: $roomId');
    _stopShakeListener();

    final result = await _repo.endRoom(roomId);
    result.fold((f) => log('[LiveRoom] End failed: ${f.errMessage}'), (_) {
      log('[LiveRoom] Room ended successfully');
      emit(LiveRoomLeft()); // Navigation handled by UI listener
    });
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _startCounterStreams() {
    _totalSub = _repo.watchTotalCounter(roomId).listen((count) {
      final s = state;
      if (s is LiveRoomLoaded) {
        final reached =
            s.room.goal > 0 && count >= s.room.goal && !s.goalReached;
        emit(
          s.copyWith(totalCount: count, goalReached: s.goalReached || reached),
        );
      }
    }, onError: (e) => log('[LiveRoom] Total stream error: $e'));

    _personalSub = _repo.watchPersonalCounter(roomId).listen((count) {
      final s = state;
      if (s is LiveRoomLoaded) {
        emit(s.copyWith(personalCount: count));
      }
    }, onError: (e) => log('[LiveRoom] Personal stream error: $e'));
  }

  void _startShakeListener() {
    _shakeSub?.cancel();
    _shakeSub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      final now = DateTime.now();
      if (magnitude > _shakeThreshold &&
          now.difference(_lastShakeTime) > _shakeCooldown) {
        _lastShakeTime = now;
        increment();
      }
    });
    log('[LiveRoom] Shake listener started');
  }

  void _startCountdown(DateTime? expiresAt) {
    _countdownTimer?.cancel();
    if (expiresAt == null) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final s = state;
      if (s is! LiveRoomLoaded) return;

      final remaining = expiresAt.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        log('[LiveRoom] Time expired! Ending room.');
        emit(LiveRoomLeft());
      } else {
        emit(s.copyWith(remainingTime: remaining));
      }
    });
  }

  void _stopShakeListener() {
    _shakeSub?.cancel();
    _shakeSub = null;
    log('[LiveRoom] Shake listener stopped');
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() {
    _totalSub?.cancel();
    _personalSub?.cancel();
    _shakeSub?.cancel();
    _countdownTimer?.cancel();
    log('[LiveRoom] Cubit closed — all subscriptions cancelled');
    return super.close();
  }
}
