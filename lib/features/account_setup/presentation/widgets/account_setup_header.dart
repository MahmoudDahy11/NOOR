import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class AccountSetupHeader extends StatelessWidget {
  const AccountSetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Setup Your',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppColors.gold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us a bit about yourself',
              style: TextStyle(fontSize: 14, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
