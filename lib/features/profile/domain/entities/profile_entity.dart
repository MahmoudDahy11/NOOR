import '../../../../features/account_setup/domain/entities/user_profile_entity.dart';
import '../../../../features/create_room/domain/entities/room_entity.dart';

class ProfileEntity {
  final UserProfileEntity user;
  final int roomsJoined;
  final int totalCounts;
  final int roomsCreated;
  final List<RoomEntity> pendingRooms;

  const ProfileEntity({
    required this.user,
    required this.roomsJoined,
    required this.totalCounts,
    required this.roomsCreated,
    required this.pendingRooms,
  });
}
