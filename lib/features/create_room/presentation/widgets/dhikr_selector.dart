import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class DhikrSelectorWidget extends StatelessWidget {
  final ValueNotifier<String?> notifier;

  static const _options = [
    'سبحان الله', 'الحمد لله', 'الله أكبر',
    'لا إله إلا الله', 'لا حول ولا قوة إلا بالله',
  ];

  const DhikrSelectorWidget({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(AppStrings.dhikr, style: TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600, color: Color(0xFF374151))),
      const SizedBox(height: 10),
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (_, selected, _) => Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            ..._options.map((d) => DhikrChip(
              label: d, isSelected: selected == d,
              onTap: () => notifier.value = d)),
            DhikrChip(label: AppStrings.custom, isSelected: selected == 'custom',
                color: AppColors.gold,
                onTap: () => notifier.value = 'custom'),
          ],
        ),
      ),
    ],
  );
}

class DhikrChip extends StatelessWidget {
  final String label; final bool isSelected;
  final VoidCallback onTap; final Color color;

  const DhikrChip({super.key, required this.label,
      required this.isSelected, required this.onTap,
      this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? color
            : color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Text(label, style: TextStyle(fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : color)),
    ),
  );
}
