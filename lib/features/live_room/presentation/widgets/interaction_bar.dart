import 'package:flutter/material.dart';

import '../cubit/live_room_cubit.dart';
import 'interaction_mode_card.dart';

class InteractionBar extends StatelessWidget {
  const InteractionBar({
    super.key,
    required this.activeMode,
    required this.isFreeRoom,
    required this.onModeChanged,
  });

  final InteractionMode activeMode;
  final bool isFreeRoom;
  final ValueChanged<InteractionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final modes = [
      const _ModeConfig(
        Icons.touch_app_rounded,
        'TOUCH',
        InteractionMode.touch,
        true,
      ),
      _ModeConfig(
        Icons.volume_up_rounded,
        'VOLUME\nKEYS',
        InteractionMode.volume,
        !isFreeRoom,
      ),
      _ModeConfig(
        Icons.headphones_rounded,
        'REMOTE\nCLICK',
        InteractionMode.remote,
        !isFreeRoom,
      ),
      _ModeConfig(
        Icons.vibration_rounded,
        'SHAKE\nPHONE',
        InteractionMode.shake,
        !isFreeRoom,
      ),
    ];
    return Row(
      children: [
        for (final mode in modes)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: InteractionModeCard(
                icon: mode.icon,
                label: mode.label,
                isActive: activeMode == mode.mode,
                isEnabled: mode.isEnabled,
                onTap: mode.isEnabled ? () => onModeChanged(mode.mode) : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _ModeConfig {
  const _ModeConfig(this.icon, this.label, this.mode, this.isEnabled);

  final IconData icon;
  final String label;
  final InteractionMode mode;
  final bool isEnabled;
}
