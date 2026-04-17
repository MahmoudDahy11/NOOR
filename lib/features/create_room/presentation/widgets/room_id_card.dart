import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class RoomIdCard extends StatelessWidget {
  final String roomId;
  const RoomIdCard({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Clipboard.setData(ClipboardData(text: roomId));
      showSnakBar(context, 'Room id copied');
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.meeting_room_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.roomID,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                roomId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: Color(0xFF1A1C1C),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.copy_rounded, color: AppColors.primary, size: 18),
        ],
      ),
    ),
  );
}

class RoomActionButtons extends StatelessWidget {
  final VoidCallback onStartNow, onLater;
  const RoomActionButtons({
    super.key,
    required this.onStartNow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: onLater,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            AppStrings.later,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: onStartNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            AppStrings.startNow,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ],
  );
}
