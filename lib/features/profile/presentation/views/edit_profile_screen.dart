import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../account_setup/presentation/widgets/avatar_picker_widget.dart';
import '../../../account_setup/presentation/widgets/section_label_widget.dart';
import '../cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileEntity profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final ValueNotifier<String> _avatarNotifier;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _avatarNotifier = ValueNotifier<String>(widget.profile.avatarAsset);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _avatarNotifier.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfileEntity(
        uid: widget.profile.uid,
        displayName: _nameController.text.trim(),
        avatarAsset: _avatarNotifier.value,
        bio: _bioController.text.trim(),
        interests: widget.profile.interests,
      );
      context.read<ProfileCubit>().updateProfile(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              showSnakBar(context, 'Profile updated successfully!');
              context.pop();
            } else if (state is ProfileError) {
              showSnakBar(context, state.message);
            }
          },
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
                        onPressed: _handleSave,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
