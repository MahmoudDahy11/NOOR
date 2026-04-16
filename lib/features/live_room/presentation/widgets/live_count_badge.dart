import 'package:flutter/material.dart';

class LiveCountBadge extends StatelessWidget {
  const LiveCountBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: Color(0xFF76FF03)),
          SizedBox(width: 6),
          Text(
            'LIVE NOW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE8F5E9),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
