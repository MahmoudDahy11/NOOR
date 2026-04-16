import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../account_setup/presentation/widgets/avatar_picker_widget.dart';
import '../../../account_setup/presentation/widgets/section_label_widget.dart';

class EditProfileForm extends StatelessWidget {
  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.bioController,
    required this.avatarNotifier,
    required this.isSaving,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController bioController;
  final ValueNotifier<String> avatarNotifier;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabelWidget(label: 'Select Avatar'),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: avatarNotifier,
                builder: (_, avatar, child) => AvatarPickerWidget(
                  selectedAvatar: avatar,
                  onSelected: (next) => avatarNotifier.value = next,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                AppStrings.displayName,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: nameController,
                hintText: 'Enter your name',
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text(AppStrings.bio, style: AppTextStyles.titleLarge),
              const SizedBox(height: 12),
              CustomTextField(
                controller: bioController,
                hintText: 'Tell us about yourself',
                prefixIcon: Icons.info_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              CustomGradientButton(
                text: 'Save Changes',
                isLoading: isSaving,
                onPressed: onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
