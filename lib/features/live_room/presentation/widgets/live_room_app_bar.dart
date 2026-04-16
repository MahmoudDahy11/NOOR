import 'package:flutter/material.dart';

/// Minimal dark-themed app bar for the Live Room screen.
///
/// Shows back button, room name, and an admin-only overflow menu
/// with the "Reset Count" option.
class LiveRoomAppBar extends StatelessWidget {
  final String roomName;
  final String roomId;
  final bool isAdmin;
  final VoidCallback onLeave;
  final VoidCallback? onReset;
  final VoidCallback? onEnd;

  const LiveRoomAppBar({
    super.key,
    required this.roomName,
    required this.roomId,
    required this.isAdmin,
    required this.onLeave,
    this.onReset,
    this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back / Leave
          IconButton(
            tooltip: 'Leave Room',
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF81C784), size: 22),
            onPressed: () => _confirmLeave(context),
          ),

          const Spacer(),

          // Center Info
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                roomName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8F5E9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ID: $roomId',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA5D6A7),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Admin menu (or spacer for symmetry)
          if (isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: Color(0xFF81C784)),
              color: const Color(0xFF143D28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'reset') {
                  _confirmReset(context);
                } else if (value == 'end') {
                  _confirmEnd(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.restart_alt_rounded,
                          color: Color(0xFFEF5350), size: 20),
                      SizedBox(width: 10),
                      Text('Reset Count',
                          style: TextStyle(color: Color(0xFFE8F5E9))),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'end',
                  child: Row(
                    children: [
                      Icon(Icons.power_settings_new_rounded,
                          color: Color(0xFFEF5350), size: 20),
                      SizedBox(width: 10),
                      Text('End Room',
                          style: TextStyle(color: Color(0xFFE8F5E9))),
                    ],
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF143D28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Room?',
            style: TextStyle(color: Color(0xFFE8F5E9))),
        content: const Text(
          'Your personal count will be preserved.',
          style: TextStyle(color: Color(0xFF81C784)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF81C784))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLeave();
            },
            child: const Text('Leave',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF143D28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Counter?',
            style: TextStyle(color: Color(0xFFE8F5E9))),
        content: const Text(
          'This will reset the total count and all participant counts to zero.',
          style: TextStyle(color: Color(0xFF81C784)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF81C784))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onReset?.call();
            },
            child: const Text('Reset',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  void _confirmEnd(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF143D28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Room?',
            style: TextStyle(color: Color(0xFFE8F5E9))),
        content: const Text(
          'This will permanently close the room for all participants and clear real-time counters.',
          style: TextStyle(color: Color(0xFF81C784)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF81C784))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onEnd?.call();
            },
            child: const Text('End Room',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }
}
