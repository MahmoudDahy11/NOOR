import 'package:flutter/material.dart';

import '../cubit/live_room_cubit.dart';

Future<void> showLeaveRoomDialog(BuildContext context, VoidCallback onLeave) {
  return _showActionDialog(
    context,
    'Leave Room?',
    'Your personal count will be preserved.',
    'Leave',
    onLeave,
  );
}

Future<void> showResetCounterDialog(
  BuildContext context,
  VoidCallback onReset,
) {
  return _showActionDialog(
    context,
    'Reset Counter?',
    'This will reset the total count and all participant counts to zero.',
    'Reset',
    onReset,
  );
}

Future<void> showEndRoomDialog(BuildContext context, VoidCallback onEnd) {
  return _showActionDialog(
    context,
    'End Room?',
    'This will permanently close the room for all participants and clear real-time counters.',
    'End Room',
    onEnd,
  );
}

Future<void> _showActionDialog(
  BuildContext context,
  String title,
  String body,
  String actionLabel,
  VoidCallback action,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF143D28),
      title: Text(title, style: const TextStyle(color: Color(0xFFE8F5E9))),
      content: Text(body, style: const TextStyle(color: Color(0xFF81C784))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            action();
          },
          child: Text(
            actionLabel,
            style: const TextStyle(color: Color(0xFFEF5350)),
          ),
        ),
      ],
    ),
  );
}

class LiveRoomMenu extends StatelessWidget {
  const LiveRoomMenu({super.key, required this.cubit});

  final LiveRoomCubit cubit;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF143D28),
      onSelected: (value) {
        if (value == 'reset') showResetCounterDialog(context, cubit.resetCount);
        if (value == 'end') showEndRoomDialog(context, cubit.endRoom);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'reset', child: Text('Reset Count')),
        PopupMenuItem(value: 'end', child: Text('End Room')),
      ],
    );
  }
}
