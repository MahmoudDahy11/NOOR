import 'package:flutter/material.dart';

import '../cubit/live_room_cubit.dart';

/// Row of four interaction-mode tiles.
///
/// • **Touch** is always enabled.
/// • **Volume / Remote / Shake** are disabled when `isFreeRoom == true`.
/// • The active tile gets a gold border and gold icon tint.
class InteractionBar extends StatelessWidget {
  final InteractionMode activeMode;
  final bool isFreeRoom;
  final ValueChanged<InteractionMode> onModeChanged;

  const InteractionBar({
    super.key,
    required this.activeMode,
    required this.isFreeRoom,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModeCard(
          icon: Icons.touch_app_rounded,
          label: 'TOUCH',
          isActive: activeMode == InteractionMode.touch,
          isEnabled: true,
          onTap: () => onModeChanged(InteractionMode.touch),
        ),
        const SizedBox(width: 10),
        _ModeCard(
          icon: Icons.volume_up_rounded,
          label: 'VOLUME\nKEYS',
          isActive: activeMode == InteractionMode.volume,
          isEnabled: !isFreeRoom,
          onTap: !isFreeRoom
              ? () => onModeChanged(InteractionMode.volume)
              : null,
        ),
        const SizedBox(width: 10),
        _ModeCard(
          icon: Icons.headphones_rounded,
          label: 'REMOTE\nCLICK',
          isActive: activeMode == InteractionMode.remote,
          isEnabled: !isFreeRoom,
          onTap: !isFreeRoom
              ? () => onModeChanged(InteractionMode.remote)
              : null,
        ),
        const SizedBox(width: 10),
        _ModeCard(
          icon: Icons.vibration_rounded,
          label: 'SHAKE\nPHONE',
          isActive: activeMode == InteractionMode.shake,
          isEnabled: !isFreeRoom,
          onTap: !isFreeRoom
              ? () => onModeChanged(InteractionMode.shake)
              : null,
        ),
      ],
    );
  }
}

// =============================================================================
// Individual mode tile
// =============================================================================

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isEnabled,
    this.onTap,
  });

  static const _gold = Color(0xFFFFD700);
  static const _greenLight = Color(0xFF81C784);
  static const _disabled = Color(0xFF2E4F3E);

  Color get _iconColor => !isEnabled
      ? _disabled
      : isActive
          ? _gold
          : _greenLight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2E7D32)
                : const Color(0xFF143D28),
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(color: _gold, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: _iconColor, size: 28),
                  if (!isEnabled)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.lock,
                        size: 12,
                        color: _disabled.withValues(alpha: 0.8),
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
                  color: _iconColor,
                  letterSpacing: 0.6,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
