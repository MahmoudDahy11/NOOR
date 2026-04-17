import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/room_entity.dart';
import 'room_id_card.dart';

class RoomCreatedSheet extends StatelessWidget {
  final RoomEntity room;
  final VoidCallback onStartNow;
  final VoidCallback onLater;

  const RoomCreatedSheet({
    super.key,
    required this.room,
    required this.onStartNow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.roomCreated,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.roomCreatedBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          RoomIdCard(roomId: room.id),
          const SizedBox(height: 24),
          RoomActionButtons(onStartNow: onStartNow, onLater: onLater),
        ],
      ),
    );
  }
}
