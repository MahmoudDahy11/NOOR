import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class InterestsPickerWidget extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  static const _options = ['Dhikr', 'Charity', 'Quran', 'Community', 'Other'];

  const InterestsPickerWidget({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  void _toggle(String item) {
    final updated = List<String>.from(selected);
    if (updated.contains(item)) {
      updated.remove(item);
    } else {
      updated.add(item);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () => _toggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
