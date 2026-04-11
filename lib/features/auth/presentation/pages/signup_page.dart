import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../cubits/signup_cubit/signup_cubit.dart';
import '../widgets/social_auth_section.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  final _autovalidateMode = ValueNotifier<AutovalidateMode>(
    AutovalidateMode.disabled,
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _autovalidateMode.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<SignupCubit>().createUserWithEmailAndPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      _autovalidateMode.value = AutovalidateMode.always;
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    return null;
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: BlocListener<SignupCubit, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              context.goNamed(AppRouter.signinRoute);
            } else if (state is SignupFailure) {
              showSnakBar(context, state.errMessage, isError: true);
              log("Signup failed: ${state.errMessage}");
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Create Account",
                    style: AppTextStyles.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Join Tally and start counting barakah",
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 40),
                  ValueListenableBuilder<AutovalidateMode>(
                    valueListenable: _autovalidateMode,
                    builder: (context, autovalidateMode, child) {
                      return Form(
                        key: _formKey,
                        autovalidateMode: autovalidateMode,
                        child: Column(
                          children: [
                            CustomTextField(
                              hintText: "Full Name",
                              prefixIcon: Icons.person_outline,
                              controller: _nameController,
                              validator: _validateName,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              hintText: "Email",
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              hintText: "Password",
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              controller: _passwordController,
                              validator: _validatePassword,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<SignupCubit, SignupState>(
                    builder: (context, state) => CustomGradientButton(
                      text: "Sign Up",
                      isLoading: state is SignupLoading,
                      onPressed: _handleSignUp,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SocialAuthSection(),
                  const SizedBox(height: 24),
                  _buildLoginPrompt(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        TextButton(
          onPressed: () => context.pushNamed(AppRouter.signinRoute),
          child: const Text(
            "Sign In",
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
