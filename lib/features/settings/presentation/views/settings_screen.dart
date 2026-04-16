import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/repo/auth_repo.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/confirm_password_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(getIt<FirebaseAuthRepo>()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        } else if (state is DeleteAccountSuccess) {
          Navigator.pop(context); // Pop loading dialog
          showSnakBar(context, 'Account deleted successfully.');
          context.goNamed(AppRouter.signinRoute);
        } else if (state is SettingsError) {
          Navigator.pop(context); // Pop loading dialog
          showSnakBar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.settings, style: AppTextStyles.titleLarge),
          backgroundColor: AppTheme.light.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildSectionHeader(context, 'General'),
            _buildSettingTile(
              context,
              title: 'App Language',
              icon: Icons.language_outlined,
              trailing: 'Arabic',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingTile(
              context,
              title: 'Theme Mode',
              icon: Icons.dark_mode_outlined,
              trailing: 'Light',
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Danger Zone'),
            _buildSettingTile(
              context,
              title: 'Delete Account',
              icon: Icons.delete_outline,
              isDestructive: true,
              onTap: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? trailing,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(
                trailing,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showSnakBar(context, 'Coming Soon');
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmPasswordDialog(
        onConfirm: (password) {
          context.read<SettingsCubit>().deleteAccount(password);
        },
      ),
    );
  }
}
