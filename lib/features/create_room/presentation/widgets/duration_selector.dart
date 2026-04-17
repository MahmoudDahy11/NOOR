import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class DurationSelectorWidget extends StatelessWidget {
  final double selectedHours;
  final ValueChanged<double> onChanged;

  static const _options = [1.0, 2.0, 3.0, 6.0, 12.0, 24.0];

  const DurationSelectorWidget({
    super.key,
    required this.selectedHours,
    required this.onChanged,
  });

  String _label(double h) {
    if (h < 1) return '${(h * 60).toInt()}m';
    if (h == h.truncate()) return '${h.toInt()}h';
    return '${h}h';
  }

  int _tickets(double h) => h.ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              AppStrings.duration,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const Spacer(),
            Text(
              '${_tickets(selectedHours)} ticket(s)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _options.map((h) {
            final isSelected = selectedHours == h;
            return GestureDetector(
              onTap: () => onChanged(h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.gold
                        : AppColors.gold.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _label(h),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.gold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
