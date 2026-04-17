import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/feed_room_entity.dart';
import 'feed_room_card_parts.dart';

class FeedRoomCard extends StatelessWidget {
  final FeedRoomEntity room;
  final bool isJoining;
  final VoidCallback onJoin;

  const FeedRoomCard({
    super.key,
    required this.room,
    required this.isJoining,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2D1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(room: room),
            const SizedBox(height: 12),
            CardDhikrProgress(room: room),
            const SizedBox(height: 16),
            CardJoinButton(room: room, isJoining: isJoining, onJoin: onJoin),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final FeedRoomEntity room;
  const _CardHeader({required this.room});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: room.isActive ? AppColors.primary : AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  room.isActive ? 'Live' : 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: room.isActive ? AppColors.primary : AppColors.gold,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.people_rounded,
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${room.participantCount}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      CardCreatorAvatar(photo: room.creator.photo, name: room.creator.name),
    ],
  );
}
