import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../widgets/social_auth_section.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text("Create Account", style: AppTextStyles.displayLarge),
              const SizedBox(height: 8),
              const Text("Join Tally and start counting barakah", style: AppTextStyles.bodyLarge),
              const SizedBox(height: 40),
              const CustomTextField(hintText: "Full Name", prefixIcon: Icons.person_outline),
              const SizedBox(height: 16),
              const CustomTextField(hintText: "Email", prefixIcon: Icons.email_outlined),
              const SizedBox(height: 16),
              const CustomTextField(hintText: "Password", prefixIcon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 32),
              CustomGradientButton(text: "Sign Up", onPressed: () {}),
              const SizedBox(height: 40),
              const SocialAuthSection(),
              const SizedBox(height: 24),
              _buildLoginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        TextButton(
          onPressed: () {},
          child: const Text("Sign In", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}