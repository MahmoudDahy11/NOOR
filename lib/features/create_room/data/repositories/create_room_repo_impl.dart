import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/create_room_params.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/create_room_repo.dart';
import '../datasource/create_room_datasource.dart';
import '../models/room_model.dart';

class CreateRoomRepoImpl implements CreateRoomRepo {
  final CreateRoomDataSource _dataSource;
  final FirebaseAuth _auth;

  CreateRoomRepoImpl({CreateRoomDataSource? dataSource, FirebaseAuth? auth})
    : _dataSource = dataSource ?? CreateRoomDataSource(),
      _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  @override
  Future<Either<CustomFailure, RoomEntity>> createRoom(
    CreateRoomParams params,
  ) async {
    try {
      log('[Repo] Fetching user data for UID: $_uid');
      final userData = await _dataSource.getUserData();

      if (params.isPaid) {
        final balance = (userData[AppKeys.ticketBalance] ?? 0) as int;
        if (balance < params.ticketsRequired) {
          return left(
            CustomFailure(errMessage: 'Not enough tickets. Visit the store.'),
          );
        }
      }

      final roomId = _dataSource.generateRoomId();
      final creator = RoomCreatorModel(
        id: _uid,
        name: userData[AppKeys.displayName] ?? '',
        photo: userData[AppKeys.avatarAsset] ?? '',
      );

      final room = RoomModel(
        id: roomId,
        name: params.name,
        type: params.type,
        dhikr: params.dhikr,
        goal: params.goal,
        currentProgress: 0,
        creator: creator,
        createdAt: DateTime.now(),
        status: AppKeys.statusPending,
        isPublic: params.isPublic,
        participants: [_uid],
        durationHours: params.durationHours,
      );

      log('[Repo] Starting data source transaction...');
      await _dataSource.saveRoom(room: room, params: params);

      log('[Repo] Transaction success. Setting RTDB counter...');
      await _dataSource.setRtdbCounter(roomId);

      log('[Repo] createRoom complete: $roomId');
      return right(room);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> startRoom(String roomId) async {
    try {
      final hours = await _dataSource.getRoomDuration(roomId);
      await _dataSource.startRoomTransaction(roomId, hours);
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, List<RoomEntity>>> getMyRooms() async {
    try {
      final rooms = await _dataSource.getUserRooms();
      return right(rooms);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
