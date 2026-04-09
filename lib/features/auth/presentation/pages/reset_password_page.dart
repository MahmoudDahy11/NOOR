import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';
import 'package:tally_islamic/core/router/app_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../cubits/forget_password_cubit/forget_password_cubit.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  final _autovalidateMode = ValueNotifier<AutovalidateMode>(
    AutovalidateMode.disabled,
  );

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
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

  void _handleSendLink() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<ForgetPasswordCubit>().sendResetLink(
        _emailController.text.trim(),
      );
    } else {
      _autovalidateMode.value = AutovalidateMode.always;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
          listener: (context, state) {
            if (state is ForgetPasswordSuccess) {
              showSnakBar(context, state.message);
              context.goNamed(AppRouter.signinRoute);
            } else if (state is ForgetPasswordFailure) {
              showSnakBar(context, state.errMessage, isError: true);
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reset Password",
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Enter your email to receive the password reset link",
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
                  CustomGradientButton(
                    text: "Send Link",
                    isLoading: state is ForgetPasswordLoading,
                    onPressed: _handleSendLink,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
