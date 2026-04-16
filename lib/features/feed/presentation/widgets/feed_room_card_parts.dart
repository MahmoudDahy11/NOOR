import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/feed_room_entity.dart';

class CardCreatorAvatar extends StatelessWidget {
  final String photo, name;
  const CardCreatorAvatar({super.key, required this.photo, required this.name});

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.primary.withValues(alpha: 0.2),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
    ),
    child: Center(child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w700, color: AppColors.primary),
    )),
  );
}

class CardDhikrProgress extends StatelessWidget {
  final FeedRoomEntity room;
  const CardDhikrProgress({super.key, required this.room});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
        begin: Alignment.centerLeft, end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(children: [
      Expanded(child: Text(room.dhikr, style: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${room.currentProgress} / ${room.goal}',
          style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 6),
        SizedBox(width: 80, child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: room.progressPercent,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 4,
          ),
        )),
      ]),
    ]),
  );
}

class CardJoinButton extends StatelessWidget {
  final FeedRoomEntity room;
  final bool isJoining;
  final VoidCallback onJoin;

  const CardJoinButton({super.key, required this.room,
      required this.isJoining, required this.onJoin});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text('by ${room.creator.name}',
      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
    const Spacer(),
    GestureDetector(
      onTap: isJoining ? null : onJoin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: room.isActive
              ? AppColors.primary : AppColors.gold.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: room.isPending
              ? Border.all(color: AppColors.gold.withValues(alpha: 0.5)) : null,
        ),
        child: isJoining
            ? const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(room.isActive ? 'Join' : 'Notify Me',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: room.isActive ? Colors.white : AppColors.gold)),
      ),
    ),
  ]);
}
