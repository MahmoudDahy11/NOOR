import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/account_setup_repo.dart';
import '../cubit/account_setup_cubit.dart';
import '../widgets/avatar_constants.dart';
import '../widgets/avatar_picker_widget.dart';
import '../widgets/interests_picker_widget.dart';
import '../widgets/section_label_widget.dart';

class AccountSetupScreen extends StatelessWidget {
  const AccountSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountSetupCubit(repo: getIt<AccountSetupRepo>()),
      child: const _AccountSetupView(),
    );
  }
}

class _AccountSetupView extends StatefulWidget {
  const _AccountSetupView();

  @override
  State<_AccountSetupView> createState() => _AccountSetupViewState();
}

class _AccountSetupViewState extends State<_AccountSetupView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _selectedAvatar = ValueNotifier<String>(AvatarConstants.defaultAvatar);
  final _selectedInterests = ValueNotifier<List<String>>([]);

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _selectedAvatar.dispose();
    _selectedInterests.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AccountSetupCubit>().saveProfile(
      displayName: _nameController.text,
      avatarAsset: _selectedAvatar.value,
      bio: _bioController.text,
      interests: _selectedInterests.value,
    );
  }

  void _handleState(BuildContext context, AccountSetupState state) {
    if (state is AccountSetupSuccess) {
      context.go(AppRouter.addCardRoute);
    } else if (state is AccountSetupFailure) {
      showSnakBar(context, state.message);
      log('Account setup failed: ${state.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountSetupCubit, AccountSetupState>(
      listener: _handleState,
      builder: (context, state) {
        final isLoading = state is AccountSetupLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [_buildHeader(), _buildBody(isLoading, context)],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tally Islamic',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Setup Your',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppColors.gold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us a bit about yourself',
              style: TextStyle(fontSize: 14, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildBody(bool isLoading, BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(28),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Avatar section
          const SectionLabelWidget(label: 'Choose your avatar'),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: _selectedAvatar,
            builder: (_, selected, _) => AvatarPickerWidget(
              selectedAvatar: selected,
              onSelected: (path) => _selectedAvatar.value = path,
            ),
          ),
          const SizedBox(height: 28),

          // Selected avatar preview
          ValueListenableBuilder<String>(
            valueListenable: _selectedAvatar,
            builder: (_, selected, _) => Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: .3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: SvgPicture.asset(selected, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Display name
          const SectionLabelWidget(label: 'Display name'),
          const SizedBox(height: 12),
          _AppTextField(
            controller: _nameController,
            hint: 'Your name',
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 24),

          // Bio
          const SectionLabelWidget(label: 'Bio'),
          const SizedBox(height: 12),
          _AppTextField(
            controller: _bioController,
            hint: 'Tell us about yourself...',
            maxLines: 3,
            maxLength: 150,
          ),
          const SizedBox(height: 24),

          // Interests
          const SectionLabelWidget(label: 'Interests'),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<String>>(
            valueListenable: _selectedInterests,
            builder: (_, selected, _) => InterestsPickerWidget(
              selected: selected,
              onChanged: (v) => _selectedInterests.value = v,
            ),
          ),
          const SizedBox(height: 40),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1C1C)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        counterStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
