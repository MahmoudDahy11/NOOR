import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/add_card_cubit.dart';
import 'card_field_widget.dart';

class AddCardFormWidget extends StatelessWidget {
  final AddCardState state;

  const AddCardFormWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isReady = state is AddCardReadyToSubmit || state is AddCardSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'Card Details'),
        const SizedBox(height: 12),
        AnimatedOpacity(
          opacity: isReady ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 300),
          child: AbsorbPointer(
            absorbing: !isReady,
            child: const StyledCardFieldWidget(),
          ),
        ),
        if (state is AddCardCreatingCustomer)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Preparing secure session...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1C),
          ),
        ),
      ],
    );
  }
}
