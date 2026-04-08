import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Reset Password", style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            const Text(
              "Enter your email to receive the password reset link",
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 40),
            const CustomTextField(
              hintText: "Email",
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 32),
            CustomGradientButton(text: "Send Link", onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
