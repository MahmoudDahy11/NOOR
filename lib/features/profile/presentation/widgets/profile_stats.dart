import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileStats extends StatelessWidget {
  final int joined;
  final int counts;
  final int created;

  const ProfileStats({
    super.key,
    required this.joined,
    required this.counts,
    required this.created,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Rooms Joined', joined.toString()),
          _buildDivider(),
          _buildStat('Counts', _formatCounts(counts)),
          _buildDivider(),
          _buildStat('Rooms Created', created.toString()),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.textHint.withAlpha((0.3 * 255).toInt()),
    );
  }

  String _formatCounts(int counts) {
    if (counts >= 1000) {
      return '${(counts / 1000).toStringAsFixed(1)}k';
    }
    return counts.toString();
  }
}
