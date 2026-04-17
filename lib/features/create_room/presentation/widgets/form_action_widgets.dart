import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/room_entity.dart';

class FormHandle extends StatelessWidget {
  final Color color;
  const FormHandle({super.key, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            AppStrings.createRoom,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1C),
            ),
          ),
        ],
      ),
    ],
  );
}

class CreateRoomSubmitButton extends StatelessWidget {
  final bool isLoading;
  final RoomType roomType;
  final VoidCallback onTap;

  const CreateRoomSubmitButton({
    super.key,
    required this.isLoading,
    required this.roomType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: roomType == RoomType.free
            ? AppColors.primary
            : AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Text(
              AppStrings.createRoom,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    ),
  );
}
