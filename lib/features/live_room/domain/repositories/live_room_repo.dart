import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/live_room_entity.dart';

/// Contract for the Live Room data operations.
///
/// • RTDB streams for real-time counters.
/// • Atomic increment of both total + personal counters.
/// • Firestore reads for room metadata.
abstract class LiveRoomRepo {
  /// Real-time stream of the global room counter from RTDB.
  Stream<int> watchTotalCounter(String roomId);

  /// Real-time stream of the current user's personal counter from RTDB.
  Stream<int> watchPersonalCounter(String roomId);

  /// Atomically increments BOTH `total` and `participants/{uid}` in RTDB.
  Future<Either<CustomFailure, void>> incrementCounter(String roomId);

  /// One-shot Firestore read for room metadata.
  Future<Either<CustomFailure, LiveRoomEntity>> getRoomDetails(String roomId);

  /// Resets the RTDB counters (admin-only — creator check done in Cubit).
  Future<Either<CustomFailure, void>> resetCounter(String roomId);

  /// Returns `true` when the current authenticated UID matches [creatorId].
  bool isCreator(String creatorId);

  /// Removes the current user from the Firestore `participants` array.
  Future<Either<CustomFailure, void>> leaveRoom(String roomId);
}
