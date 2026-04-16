import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/feed_room_entity.dart';

abstract class FeedRepo {
  /// Fetches public rooms sorted by createdAt desc.
  /// [status] = 'active' | 'pending'
  Future<Either<CustomFailure, List<FeedRoomEntity>>> getRooms({
    required String status,
    FeedRoomEntity? lastRoom, // for pagination
  });

  /// Join a public room — adds userId to participants.
  Future<Either<CustomFailure, void>> joinRoom(String roomId);

  /// Validate private room ID exists and is joinable.
  Future<Either<CustomFailure, FeedRoomEntity>> getRoomById(String roomId);
}
