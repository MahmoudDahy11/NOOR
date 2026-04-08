import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../data/service/otp_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late TextEditingController _emailController;
  final OtpService _otpService = OtpService();
  final ValueNotifier<bool> _isSending = ValueNotifier<bool>(false);
  
  final _formKey = GlobalKey<FormState>();
  final _autovalidateMode = ValueNotifier<AutovalidateMode>(AutovalidateMode.disabled);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _isSending.dispose();
    _autovalidateMode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _handleSendLink() async {
    if (!_formKey.currentState!.validate()) {
      _autovalidateMode.value = AutovalidateMode.always;
      return;
    }

    final email = _emailController.text.trim();

    _isSending.value = true;

    try {
      final otp = _otpService.generateOtp();
      // Use email as temporary id for password reset OTP verification
      await _otpService.saveOtp(email, otp);
      await _otpService.sendOtpToEmail(email, otp);

      // Store email temporarily for OTP verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reset_email', email);

      if (!mounted) return;

      showSnakBar(context, "OTP sent to your email");
      context.pushNamed(AppRouter.otpRoute);
    } catch (e) {
      if (!mounted) return;
      showSnakBar(context, "Failed to send OTP: $e", isError: true);
    } finally {
      if (mounted) {
        _isSending.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Reset Password", style: AppTextStyles.headlineMedium),
              const SizedBox(height: 12),
              const Text(
                "Enter your email to receive the password reset code",
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 40),
              ValueListenableBuilder<AutovalidateMode>(
                valueListenable: _autovalidateMode,
                builder: (context, autovalidateMode, child) {
                  return Form(
                    key: _formKey,
                    autovalidateMode: autovalidateMode,
                    child: CustomTextField(
                      hintText: "Email",
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      validator: _validateEmail,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ValueListenableBuilder<bool>(
                valueListenable: _isSending,
                builder: (context, isSending, child) {
                  return CustomGradientButton(
                    text: "Send Code",
                    isLoading: isSending,
                    onPressed: isSending ? () {} : _handleSendLink,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
