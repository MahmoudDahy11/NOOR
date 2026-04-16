import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/router/app_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../domain/repo/otp_repo.dart';
import '../cubits/otp_cubit/otp_cubit.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpCubit(getIt<OtpRepository>()),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView();

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
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

  void _handleResendOtp() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
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
              CustomGradientButton(
                text: "Verify",
                isLoading: false,
                onPressed: () {
                  context.goNamed(AppRouter.signinRoute);
                },
              ),
              const SizedBox(height: 24),
              _buildResendSection(),
            ],
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
        const Text(AppStrings.didntReceiveCode),
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
