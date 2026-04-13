import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

enum RoomType { free, paid }

class CreateRoomTypeSheet extends StatelessWidget {
  final ValueChanged<RoomType> onSelected;
  const CreateRoomTypeSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 24),
          _SheetTitle(),
          const SizedBox(height: 8),
          const Text(
            'Choose room type to get started',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: RoomTypeCard(
                  type: RoomType.free,
                  title: 'Free',
                  subtitle: '30 min',
                  detail: 'Up to 2,000 counts',
                  icon: Icons.lock_open_rounded,
                  color: AppColors.primary,
                  onTap: () => onSelected(RoomType.free),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RoomTypeCard(
                  type: RoomType.paid,
                  title: 'Paid',
                  subtitle: '6 hrs+',
                  detail: 'Unlimited counts',
                  icon: Icons.workspace_premium_rounded,
                  color: AppColors.gold,
                  onTap: () => onSelected(RoomType.paid),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _SheetTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      const Text(
        'Create a Room',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1C1C),
        ),
      ),
    ],
  );
}

class RoomTypeCard extends StatelessWidget {
  final RoomType type;
  final String title, subtitle, detail;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const RoomTypeCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
