import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SectionLabelWidget extends StatelessWidget {
  final String label;

  const SectionLabelWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1C),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
