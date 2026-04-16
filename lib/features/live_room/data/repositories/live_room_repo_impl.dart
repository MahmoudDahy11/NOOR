import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/live_room_entity.dart';
import '../../domain/repositories/live_room_repo.dart';
import '../datasource/live_room_datasource.dart';
import '../models/live_room_model.dart';

class LiveRoomRepoImpl implements LiveRoomRepo {
  final LiveRoomDataSource _dataSource;

  LiveRoomRepoImpl({required LiveRoomDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<int> watchTotalCounter(String roomId) =>
      _dataSource.watchTotalCounter(roomId);

  @override
  Stream<int> watchPersonalCounter(String roomId) =>
      _dataSource.watchPersonalCounter(roomId);

  @override
  Future<Either<CustomFailure, void>> incrementCounter(String roomId) async {
    try {
      await _dataSource.incrementCounters(roomId);
      return right(null);
    } catch (e) {
      log('[LiveRoomRepo] Increment failed: $e');
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, LiveRoomEntity>> getRoomDetails(
    String roomId,
  ) async {
    try {
      final data = await _dataSource.getRoomData(roomId);
      final model = LiveRoomModel.fromFirestore(data, roomId);
      return right(model);
    } catch (e) {
      log('[LiveRoomRepo] getRoomDetails failed: $e');
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> resetCounter(String roomId) async {
    try {
      await _dataSource.resetCounters(roomId);
      return right(null);
    } catch (e) {
      log('[LiveRoomRepo] resetCounter failed: $e');
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  bool isCreator(String creatorId) => _dataSource.isCreator(creatorId);

  @override
  Future<Either<CustomFailure, void>> leaveRoom(String roomId) async {
    try {
      await _dataSource.removeParticipant(roomId);
      return right(null);
    } catch (e) {
      log('[LiveRoomRepo] leaveRoom failed: $e');
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> endRoom(String roomId) async {
    try {
      await _dataSource.completeRoom(roomId);
      return right(null);
    } catch (e) {
      log('[LiveRoomRepo] endRoom failed: $e');
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
