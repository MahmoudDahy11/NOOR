import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import 'app_text_field.dart';
import 'avatar_picker_widget.dart';
import 'interests_picker_widget.dart';
import 'section_label_widget.dart';

class AccountSetupBody extends StatelessWidget {
  final ValueNotifier<String> selectedAvatar;
  final ValueNotifier<List<String>> selectedInterests;
  final TextEditingController nameController;
  final TextEditingController bioController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const AccountSetupBody({
    super.key,
    required this.selectedAvatar,
    required this.selectedInterests,
    required this.nameController,
    required this.bioController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(28),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Avatar section
          const SectionLabelWidget(label: 'Choose your avatar'),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: selectedAvatar,
            builder: (_, selected, _) => AvatarPickerWidget(
              selectedAvatar: selected,
              onSelected: (path) => selectedAvatar.value = path,
            ),
          ),
          const SizedBox(height: 28),

          // Selected avatar preview
          ValueListenableBuilder<String>(
            valueListenable: selectedAvatar,
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
          AppTextField(
            controller: nameController,
            hint: 'Your name',
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 24),

          // Bio
          const SectionLabelWidget(label: 'Bio'),
          const SizedBox(height: 12),
          AppTextField(
            controller: bioController,
            hint: 'Tell us about yourself...',
            maxLines: 3,
            maxLength: 150,
          ),
          const SizedBox(height: 24),

          // Interests
          const SectionLabelWidget(label: 'Interests'),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<String>>(
            valueListenable: selectedInterests,
            builder: (_, selected, _) => InterestsPickerWidget(
              selected: selected,
              onChanged: (v) => selectedInterests.value = v,
            ),
          ),
          const SizedBox(height: 40),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
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
