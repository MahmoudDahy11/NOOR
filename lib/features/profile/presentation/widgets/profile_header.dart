import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  final String avatar;
  final String name;
  final String? userName;
  final String bio;

  const ProfileHeader({
    super.key,
    required this.avatar,
    required this.name,
    this.userName,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.background,
            child: avatar.endsWith('.svg')
                ? SvgPicture.asset(avatar)
                : Image.asset(avatar),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: AppTextStyles.headlineMedium),
        if (userName != null) ...[
          const SizedBox(height: 4),
          Text(
            userName!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              bio,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }
}
