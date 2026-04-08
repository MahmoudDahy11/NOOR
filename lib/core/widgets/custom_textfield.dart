import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final obscureTextNotifier = ValueNotifier<bool>(true);

    return ValueListenableBuilder(
      valueListenable: obscureTextNotifier,
      builder: (context, isObscured, _) {
        return TextFormField(
          controller: controller,
          obscureText: isPassword ? isObscured : false,
          validator: validator,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary)
                : null,
            suffixIcon: isPassword
                ? _buildPasswordIcon(obscureTextNotifier, isObscured)
                : null,
            filled: true,
            fillColor: AppColors.surface,
            border: _buildBorder(),
            enabledBorder: _buildBorder(),
            focusedBorder: _buildBorder(AppColors.primary),
            errorBorder: _buildBorder(AppColors.error),
          ),
        );
      },
    );
  }

  Widget _buildPasswordIcon(ValueNotifier<bool> notifier, bool isObscured) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off : Icons.visibility,
        color: AppColors.textSecondary,
      ),
      onPressed: () => notifier.value = !notifier.value,
    );
  }

  OutlineInputBorder _buildBorder([Color color = Colors.transparent]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
