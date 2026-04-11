import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CardVisualWidget extends StatelessWidget {
  const CardVisualWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A6B3F), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TALLY',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: 2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: const Text('SECURE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: AppColors.gold, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text('•••• •••• •••• ••••',
            style: TextStyle(fontSize: 20, color: Colors.white70,
                letterSpacing: 4, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MM / YY',
                style: TextStyle(fontSize: 12, color: Colors.white54,
                    letterSpacing: 1),
              ),
              Row(
                children: [
                  Container(width: 28, height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFEB001B),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-10, 0),
                    child: Container(width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF79E1B).withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
