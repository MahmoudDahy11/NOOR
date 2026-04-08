import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../widgets/social_auth_section.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 40),
              const Text("Sign In", style: AppTextStyles.displayLarge),
              const SizedBox(height: 8),
              const Text(
                "Welcome back to Tally",
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 40),
              const CustomTextField(
                hintText: "Email",
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                hintText: "Password",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              _buildForgotPassword(),
              const SizedBox(height: 32),
              CustomGradientButton(text: "Sign In", onPressed: () {}),
              const SizedBox(height: 40),
              const SocialAuthSection(),
              const SizedBox(height: 24),
              _buildSignupPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Center(
      child: Icon(Icons.auto_graph_rounded, size: 80, color: AppColors.primary),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildSignupPrompt() {
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
