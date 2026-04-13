import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'create_room_type_sheet.dart';
import 'sheet_components.dart';

class DhikrSelectorWidget extends StatelessWidget {
  final String? selectedDhikr;
  final ValueChanged<String> onSelected;

  static const options = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'لا حول ولا قوة إلا بالله',
  ];

  const DhikrSelectorWidget({
    super.key,
    required this.selectedDhikr,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SheetLabel(label: 'Choose Dhikr'),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...options.map(
            (d) => DhikrChip(
              label: d,
              isSelected: selectedDhikr == d,
              onTap: () => onSelected(d),
            ),
          ),
          DhikrChip(
            label: 'Custom ✏️',
            isSelected: selectedDhikr == 'custom',
            color: AppColors.gold,
            onTap: () => onSelected('custom'),
          ),
        ],
      ),
    ],
  );
}

class VisibilityToggle extends StatelessWidget {
  final bool isPublic;
  final VoidCallback onToggle;

  const VisibilityToggle({
    super.key,
    required this.isPublic,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const SheetLabel(label: 'Visibility'),
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

class CreateRoomButton extends StatelessWidget {
  final RoomType roomType;
  final bool isLoading;
  final VoidCallback onTap;

  const CreateRoomButton({
    super.key,
    required this.roomType,
    required this.isLoading,
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
              'Create Room',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    ),
  );
}
