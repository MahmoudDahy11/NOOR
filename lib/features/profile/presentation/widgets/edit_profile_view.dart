import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../cubit/profile_cubit.dart';
import 'edit_profile_form.dart';
import 'profile_error_state.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  UserProfileEntity? _profile;
  TextEditingController? _nameController;
  TextEditingController? _bioController;
  ValueNotifier<String>? _avatarNotifier;

  @override
  void dispose() {
    _nameController?.dispose();
    _bioController?.dispose();
    _avatarNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.reactionId != current.reactionId,
        listener: _handleReaction,
        builder: (context, state) {
          _syncProfile(state.profile?.user);
          if (_profile == null && state.isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_profile == null) {
            return ProfileErrorState(
              message: state.message ?? 'Failed to load profile.',
              onRetry: context.read<ProfileCubit>().getProfile,
            );
          }
          return EditProfileForm(
            formKey: _formKey,
            nameController: _nameController!,
            bioController: _bioController!,
            avatarNotifier: _avatarNotifier!,
            isSaving: state.isSaving,
            onSave: () => _save(context),
          );
        },
      ),
    );
  }

  void _syncProfile(UserProfileEntity? next) {
    if (next == null || _profile != null) return;
    _profile = next;
    _nameController = TextEditingController(text: next.displayName);
    _bioController = TextEditingController(text: next.bio);
    _avatarNotifier = ValueNotifier<String>(next.avatarAsset);
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate() || _profile == null) return;
    context.read<ProfileCubit>().updateProfile(
      UserProfileEntity(
        uid: _profile!.uid,
        displayName: _nameController!.text.trim(),
        avatarAsset: _avatarNotifier!.value,
        bio: _bioController!.text.trim(),
        interests: _profile!.interests,
      ),
    );
  }

  void _handleReaction(BuildContext context, ProfileState state) {
    if (state.outcome == ProfileOutcome.updated) {
      showSnakBar(context, 'Profile updated successfully!');
      log('Profile updated successfully!');
      Navigator.pop(context, true);
    } else if (state.outcome == ProfileOutcome.error && state.message != null) {
      showSnakBar(context, state.message!, isError: true);
      log('Profile update failed: ${state.message}');
    }
  }
}
