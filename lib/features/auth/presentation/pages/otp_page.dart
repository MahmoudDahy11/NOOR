import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../cubits/otp_cubit/otp_cubit.dart';
import '../cubits/otp_cubit/otp_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() => _controllers.map((c) => c.text).join();

  Future<void> _handleVerifyOtp() async {
    final otp = _getOtpCode();
    if (otp.length != 4) {
      showSnakBar(context, "Please enter all 4 digits", isError: true);
      return;
    }

    // Check if this is password reset flow
    final prefs = await SharedPreferences.getInstance();
    final resetEmail = prefs.getString('reset_email');

    String userId;
    if (resetEmail != null) {
      // Password reset flow - use email as id
      userId = resetEmail;
    } else {
      // Signup/Signin flow - use Firebase uid
      final currentUser = FirebaseAuth.instance.currentUser?.uid;
      if (currentUser == null) {
        showSnakBar(context, "User not authenticated", isError: true);
        return;
      }
      userId = currentUser;
    }

    context.read<OtpCubit>().verifyOtp(uid: userId, enteredOtp: otp);
  }

  Future<void> _handleResendOtp() async {
    // Check if this is password reset flow
    final prefs = await SharedPreferences.getInstance();
    final resetEmail = prefs.getString('reset_email');

    if (resetEmail != null) {
      // Password reset flow
      showSnakBar(context, "Resend OTP not yet implemented for password reset");
      return;
    }

    // Signup/Signin flow
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userId == null || userEmail == null) {
      showSnakBar(context, "User authentication required", isError: true);
      return;
    }

    context.read<OtpCubit>().sendOtp(uid: userId, email: userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocListener<OtpCubit, OtpState>(
          listener: (context, state) async {
            if (state is OtpVerified) {
              final prefs = await SharedPreferences.getInstance();
              final resetEmail = prefs.getString('reset_email');

              // Cleanup temporary reset email
              if (resetEmail != null) {
                await prefs.remove('reset_email');
                // Password reset successful - navigate to signin
                if (context.mounted) {
                  showSnakBar(context, "OTP verified successfully");
                  context.goNamed(AppRouter.signinRoute);
                }
              } else {
                // Signup flow - navigate to home
                if (context.mounted) {
                  context.go('/');
                }
              }
            } else if (state is OtpError) {
              showSnakBar(context, state.errmessage, isError: true);
            } else if (state is OtpSent) {
              showSnakBar(context, "OTP sent successfully");
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "OTP Verification",
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Enter the 4-digit code sent to your email",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildOtpFields(),
                const SizedBox(height: 48),
                BlocBuilder<OtpCubit, OtpState>(
                  builder: (context, state) => CustomGradientButton(
                    text: "Verify",
                    isLoading: state is OtpLoading,
                    onPressed: _handleVerifyOtp,
                  ),
                ),
                const SizedBox(height: 24),
                _buildResendSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) => _otpBox(index)),
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
        },
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
          onPressed: _handleResendOtp,
          child: const Text(
            "Resend",
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
