import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/live_room_entity.dart';
import '../../domain/repositories/live_room_repo.dart';
import '../datasource/live_room_datasource.dart';
import '../models/live_room_model.dart';

class LiveRoomRepoImpl implements LiveRoomRepo {
  LiveRoomRepoImpl({required LiveRoomDataSource dataSource})
    : _dataSource = dataSource;

  final LiveRoomDataSource _dataSource;

  @override
  Stream<int> watchTotalCounter(String roomId) =>
      _dataSource.watchTotalCounter(roomId);

  @override
  Stream<int> watchPersonalCounter(String roomId) =>
      _dataSource.watchPersonalCounter(roomId);

  @override
  Future<Either<CustomFailure, void>> incrementCounter(String roomId) =>
      _runVoid(() => _dataSource.incrementCounters(roomId));

  @override
  Future<Either<CustomFailure, LiveRoomEntity>> getRoomDetails(String roomId) =>
      _runValue(() async {
        final data = await _dataSource.getRoomData(roomId);
        return LiveRoomModel.fromFirestore(data, roomId);
      });

  @override
  Future<Either<CustomFailure, void>> resetCounter(String roomId) =>
      _runVoid(() => _dataSource.resetCounters(roomId));

  @override
  bool isCreator(String creatorId) => _dataSource.isCreator(creatorId);

  @override
  Future<Either<CustomFailure, void>> leaveRoom(String roomId) =>
      _runVoid(() => _dataSource.removeParticipant(roomId));

  @override
  Future<Either<CustomFailure, void>> endRoom(String roomId) =>
      _runVoid(() => _dataSource.completeRoom(roomId));

  Future<Either<CustomFailure, void>> _runVoid(
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return right(null);
    } catch (error) {
      return left(CustomFailure(errMessage: error.toString()));
    }
  }

  Future<Either<CustomFailure, T>> _runValue<T>(
    Future<T> Function() action,
  ) async {
    try {
      return right(await action());
    } catch (error) {
      return left(CustomFailure(errMessage: error.toString()));
    }
  }
}
