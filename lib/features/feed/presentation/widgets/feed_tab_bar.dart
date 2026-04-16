import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class FeedTabBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const FeedTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Active',
            value: 'active',
            isSelected: activeTab == 'active',
            onTap: () => onTabChanged('active'),
          ),
          _Tab(
            label: 'Pending',
            value: 'pending',
            isSelected: activeTab == 'pending',
            onTap: () => onTabChanged('pending'),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label, value;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
