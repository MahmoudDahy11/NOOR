import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileMenu extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onSignOut;

  const ProfileMenu({
    super.key,
    required this.onEditProfile,
    required this.onSettings,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: onEditProfile,
        ),
        _buildMenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: onSettings,
        ),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Sign Out',
          color: AppColors.error,
          onTap: onSignOut,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final themeColor = color ?? AppColors.primary;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeColor.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: themeColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: color ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.textHint,
      ),
    );
  }
}
