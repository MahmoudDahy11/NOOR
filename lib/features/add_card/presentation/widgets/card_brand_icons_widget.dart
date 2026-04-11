import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CardBrandIconsWidget extends StatelessWidget {
  const CardBrandIconsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _BrandBadge(label: 'VISA', color: Color(0xFF1A1F71)),
        const SizedBox(width: 8),
        const _BrandBadge(label: 'MC', color: Color(0xFFEB001B)),
        const SizedBox(width: 8),
        const _BrandBadge(label: 'AMEX', color: Color(0xFF2E77BC)),
        const Spacer(),
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 13,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Secured by Stripe',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _BrandBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
