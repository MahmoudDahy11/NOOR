import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../account_setup/presentation/widgets/avatar_picker_widget.dart';
import '../../../account_setup/presentation/widgets/section_label_widget.dart';
import '../cubit/profile_cubit.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => getIt<ProfileCubit>()..getProfile(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late ValueNotifier<String> _avatarNotifier;
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  void _initializeControllers(UserProfileEntity profile) {
    if (_isInitialized) return;
    _nameController = TextEditingController(text: profile.displayName);
    _bioController = TextEditingController(text: profile.bio);
    _avatarNotifier = ValueNotifier<String>(profile.avatarAsset);
    _isInitialized = true;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _nameController.dispose();
      _bioController.dispose();
      _avatarNotifier.dispose();
    }
    super.dispose();
  }

  void _handleSave(UserProfileEntity originalProfile) {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfileEntity(
        uid: originalProfile.uid,
        displayName: _nameController.text.trim(),
        avatarAsset: _avatarNotifier.value,
        bio: _bioController.text.trim(),
        interests: originalProfile.interests,
      );
      context.read<ProfileCubit>().updateProfile(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            showSnakBar(context, 'Profile updated successfully!');
            Navigator.pop(context, true);
          } else if (state is ProfileError) {
            showSnakBar(context, state.message);
            log('Profile Error: ${state.message}');
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileSuccess || _isInitialized) {
            final profile = (state is ProfileSuccess) ? state.profile.user : null;
            if (profile != null) _initializeControllers(profile);

            if (!_isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentUserProfile = (state is ProfileSuccess) ? state.profile.user : null;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabelWidget(label: 'Select Avatar'),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<String>(
                        valueListenable: _avatarNotifier,
                        builder: (context, selectedAvatar, _) {
                          return AvatarPickerWidget(
                            selectedAvatar: selectedAvatar,
                            onSelected: (avatar) => _avatarNotifier.value = avatar,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text('Display Name', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Enter your name',
                        prefixIcon: Icons.person_outline,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      const Text('Bio', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _bioController,
                        hintText: 'Tell us about yourself',
                        prefixIcon: Icons.info_outline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 40),
                      BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          return CustomGradientButton(
                            text: 'Save Changes',
                            isLoading: state is ProfileLoading,
                            onPressed: () {
                              final p = (state is ProfileSuccess) ? state.profile.user : currentUserProfile;
                              if (p != null) _handleSave(p);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
