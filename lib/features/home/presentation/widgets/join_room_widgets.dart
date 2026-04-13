import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class JoinSheetHandle extends StatelessWidget {
  const JoinSheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class JoinSheetHeader extends StatelessWidget {
  const JoinSheetHeader({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Join a Room',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1C),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      const Text(
        'Enter the 8-character room ID',
        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
      ),
    ],
  );
}

class JoinIdField extends StatelessWidget {
  final TextEditingController controller;
  const JoinIdField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    textCapitalization: TextCapitalization.characters,
    maxLength: 8,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: 6,
      color: Color(0xFF1A1C1C),
    ),
    decoration: InputDecoration(
      hintText: 'ABC12345',
      counterText: '',
      hintStyle: TextStyle(
        fontSize: 20,
        letterSpacing: 4,
        color: Colors.grey.shade300,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAF9),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}

class JoinButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const JoinButton({super.key, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Text(
              'Join Room',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    ),
  );
}
