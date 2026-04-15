import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entity/ticket_package_entity.dart';
import 'ticket_card_parts.dart';

class TicketCardWidget extends StatelessWidget {
  final TicketPackageEntity package;
  final bool isPurchasing;
  final VoidCallback onTap;

  const TicketCardWidget({
    super.key,
    required this.package,
    required this.isPurchasing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPurchasing ? null : onTap,
      child: RepaintBoundary(
        child: Stack(
          children: [
            _GoldenCard(package: package),
            if (package.isPopular) const PopularBadge(),
            if (isPurchasing) const PurchasingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _GoldenCard extends StatelessWidget {
  final TicketPackageEntity package;
  const _GoldenCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB8860B), Color(0xFFFFD700), Color(0xFFDAA520)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TicketCardContent(package: package),
    );
  }
}
