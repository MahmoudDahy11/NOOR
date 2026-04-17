import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/create_room_params.dart';
import '../entities/room_entity.dart';

abstract class CreateRoomRepo {
  /// Creates room in Firestore + initializes RTDB counter.
  /// Deducts tickets if paid room.
  /// Room starts as 'pending' — user activates later.
  Future<Either<CustomFailure, RoomEntity>> createRoom(CreateRoomParams params);

  /// Activates a pending room — sets status to 'active' and expiresAt.
  Future<Either<CustomFailure, void>> startRoom(String roomId);

  /// Fetches rooms created by current user (profile page).
  Future<Either<CustomFailure, List<RoomEntity>>> getMyRooms();
}
