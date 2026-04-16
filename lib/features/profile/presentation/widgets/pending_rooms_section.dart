import 'package:flutter/material.dart';

import '../../../create_room/domain/entities/room_entity.dart';
import 'pending_room_card.dart';

class PendingRoomsSection extends StatelessWidget {
  const PendingRoomsSection({
    super.key,
    required this.rooms,
    required this.isLoading,
    required this.onStart,
  });

  final List<RoomEntity> rooms;
  final bool isLoading;
  final ValueChanged<String> onStart;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Rooms to Start',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: rooms.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (_, index) => PendingRoomCard(
              room: rooms[index],
              isLoading: isLoading,
              onStart: () => onStart(rooms[index].id),
            ),
          ),
        ),
      ],
    );
  }
}
