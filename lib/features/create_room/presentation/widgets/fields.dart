import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/room_entity.dart';

class RoomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final TextInputType keyboardType;
  final String? suffix;
  final String? Function(String?)? validator;

  const RoomFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1A1C1C)),
        decoration: InputDecoration(
          hintText: hint,
          suffixText: suffix,
          hintStyle: const TextStyle(color: Color(0xFFB0B8C1), fontSize: 14),
          suffixStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAF9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
      ),
    ],
  );
}

class RoomGoalField extends StatelessWidget {
  final TextEditingController controller;
  final RoomType roomType;
  const RoomGoalField({
    super.key,
    required this.controller,
    required this.roomType,
  });

  @override
  Widget build(BuildContext context) => RoomFormField(
    controller: controller,
    label: AppStrings.collectiveGoal,
    hint: '100',
    keyboardType: TextInputType.number,
    suffix: 'counts',
    validator: (v) {
      final n = int.tryParse(v ?? '');
      if (n == null || n <= 0) return 'Enter a valid number';
      final max = roomType == RoomType.free ? 2000 : 1000000;
      if (n > max) return 'Max $max for this type';
      return null;
    },
  );
}

class VisibilityToggleRow extends StatelessWidget {
  final bool isPublic;
  final VoidCallback onToggle;
  const VisibilityToggleRow({
    super.key,
    required this.isPublic,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Text(
        AppStrings.visibility,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPublic
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPublic
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPublic ? Icons.public_rounded : Icons.lock_rounded,
                size: 16,
                color: isPublic ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                isPublic ? 'Public' : 'Private',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPublic ? AppColors.primary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
