import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("OTP Verification", style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            const Text(
              "Enter the 4-digit code sent to your email",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildOtpFields(),
            const SizedBox(height: 48),
            CustomGradientButton(text: "Verify", onPressed: () {}),
            const SizedBox(height: 24),
            _buildResendSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) => _otpBox()),
    );
  }

  Widget _otpBox() {
    return SizedBox(
      width: 60,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textHint),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Didn't receive code? "),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Resend",
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
