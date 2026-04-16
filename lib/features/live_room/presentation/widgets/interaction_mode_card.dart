import 'package:flutter/material.dart';

class InteractionModeCard extends StatelessWidget {
  const InteractionModeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isEnabled,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = !isEnabled
        ? const Color(0xFF2E4F3E)
        : isActive
        ? const Color(0xFFFFD700)
        : const Color(0xFF81C784);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2E7D32) : const Color(0xFF143D28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFFFFD700) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: iconColor, size: 28),
                if (!isEnabled)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.lock,
                      size: 12,
                      color: iconColor.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: iconColor,
                letterSpacing: 0.6,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
