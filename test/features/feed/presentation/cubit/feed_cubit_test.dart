import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_islamic/core/error/failure.dart';
import 'package:tally_islamic/features/feed/domain/entities/feed_room_entity.dart';
import 'package:tally_islamic/features/feed/domain/repositories/feed_repo.dart';
import 'package:tally_islamic/features/feed/presentation/cubit/feed_cubit.dart';

class _FakeFeedRepo implements FeedRepo {
  _FakeFeedRepo({required this.rooms, this.notifyMeResult});

  final List<FeedRoomEntity> rooms;
  final Either<CustomFailure, void>? notifyMeResult;

  @override
  Future<Either<CustomFailure, List<FeedRoomEntity>>> getRooms({
    required String status,
    FeedRoomEntity? lastRoom,
  }) async {
    return right(rooms.where((room) => room.status == status).toList());
  }

  @override
  Future<Either<CustomFailure, FeedRoomEntity>> getRoomById(
    String roomId,
  ) async {
    return right(rooms.firstWhere((room) => room.id == roomId));
  }

  @override
  Future<Either<CustomFailure, void>> joinRoom(String roomId) async {
    return right(null);
  }

  @override
  Future<Either<CustomFailure, void>> notifyMe(String roomId) async {
    return notifyMeResult ?? right(null);
  }
}

FeedRoomEntity _room({required String id, required String status}) {
  return FeedRoomEntity(
    id: id,
    name: 'Room $id',
    dhikr: 'SubhanAllah',
    goal: 100,
    currentProgress: 20,
    status: status,
    isPublic: true,
    creator: const FeedRoomCreator(id: 'creator-1', name: 'Creator', photo: ''),
    createdAt: DateTime(2026, 4, 17),
    participantCount: 3,
    type: 'free',
  );
}

void main() {
  group('FeedCubit notifyMe', () {
    test('emits notifying then success for pending room reminders', () async {
      final cubit = FeedCubit(
        repo: _FakeFeedRepo(
          rooms: [_room(id: 'room-1', status: 'pending')],
        ),
      );

      final emittedStates = <FeedState>[];
      final subscription = cubit.stream.listen(emittedStates.add);

      await cubit.loadFeed(tab: 'pending');
      await cubit.notifyMe('room-1');
      await Future<void>.delayed(Duration.zero);

      expect(emittedStates[0], isA<FeedLoading>());
      expect(emittedStates[1], isA<FeedLoaded>());
      expect(emittedStates[2], isA<FeedNotifying>());
      expect(emittedStates[3], isA<FeedNotifyMeSuccess>());

      final success = emittedStates[3] as FeedNotifyMeSuccess;
      expect(success.roomId, 'room-1');
      expect(success.activeTab, 'pending');

      await subscription.cancel();
      await cubit.close();
    });

    test('emits failure with current tab when reminder save fails', () async {
      final cubit = FeedCubit(
        repo: _FakeFeedRepo(
          rooms: [_room(id: 'room-1', status: 'pending')],
          notifyMeResult: left(CustomFailure(errMessage: 'permission-denied')),
        ),
      );

      final emittedStates = <FeedState>[];
      final subscription = cubit.stream.listen(emittedStates.add);

      await cubit.loadFeed(tab: 'pending');
      await cubit.notifyMe('room-1');
      await Future<void>.delayed(Duration.zero);

      expect(emittedStates[2], isA<FeedNotifying>());
      expect(emittedStates[3], isA<FeedFailure>());

      final failure = emittedStates[3] as FeedFailure;
      expect(failure.message, 'permission-denied');
      expect(failure.activeTab, 'pending');

      await subscription.cancel();
      await cubit.close();
    });
  });
}
