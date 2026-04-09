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
import '../cubits/login_cubit/login_cubit.dart';
import '../widgets/social_auth_section.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  final _autovalidateMode = ValueNotifier<AutovalidateMode>(AutovalidateMode.disabled);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _autovalidateMode.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      _autovalidateMode.value = AutovalidateMode.always;
    }
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
        body: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              context.go('/');
              log("Login successful");
            } else if (state is LoginFailure) {
              showSnakBar(context, state.errMessage, isError: true);
              log("Login failed: ${state.errMessage}");
            }
          },
          child: SafeArea(
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
                  ValueListenableBuilder<AutovalidateMode>(
                    valueListenable: _autovalidateMode,
                    builder: (context, autovalidateMode, child) {
                      return Form(
                        key: _formKey,
                        autovalidateMode: autovalidateMode,
                        child: Column(
                          children: [
                            CustomTextField(
                              hintText: "Email",
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 20),
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
                  _buildForgotPassword(context),
                  const SizedBox(height: 32),
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) => CustomGradientButton(
                      text: "Sign In",
                      isLoading: state is LoginLoading,
                      onPressed: _handleSignIn,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SocialAuthSection(),
                  const SizedBox(height: 24),
                  _buildSignupPrompt(context),
                ],
              ),
            ),
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

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => context.pushNamed(AppRouter.resetPasswordRoute),
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildSignupPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () => context.pushNamed(AppRouter.signupRoute),
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
