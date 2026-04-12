import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/account_setup_repo.dart';
import '../cubit/account_setup_cubit.dart';
import '../widgets/account_setup_body.dart';
import '../widgets/account_setup_header.dart';
import '../widgets/avatar_constants.dart';

class AccountSetupScreen extends StatelessWidget {
  const AccountSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountSetupCubit(repo: getIt<AccountSetupRepo>()),
      child: const _AccountSetupView(),
    );
  }
}

class _AccountSetupView extends StatefulWidget {
  const _AccountSetupView();

  @override
  State<_AccountSetupView> createState() => _AccountSetupViewState();
}

class _AccountSetupViewState extends State<_AccountSetupView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _selectedAvatar = ValueNotifier<String>(AvatarConstants.defaultAvatar);
  final _selectedInterests = ValueNotifier<List<String>>([]);

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _selectedAvatar.dispose();
    _selectedInterests.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AccountSetupCubit>().saveProfile(
      displayName: _nameController.text,
      avatarAsset: _selectedAvatar.value,
      bio: _bioController.text,
      interests: _selectedInterests.value,
    );
  }

  void _handleState(BuildContext context, AccountSetupState state) {
    if (state is AccountSetupSuccess) {
      log('Account setup success');
      context.go(AppRouter.addCardRoute);
    } else if (state is AccountSetupFailure) {
      showSnakBar(context, state.message);
      log('Account setup failed: ${state.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountSetupCubit, AccountSetupState>(
      listener: _handleState,
      builder: (context, state) {
        final isLoading = state is AccountSetupLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [
                  const AccountSetupHeader(),
                  AccountSetupBody(
                    selectedAvatar: _selectedAvatar,
                    selectedInterests: _selectedInterests,
                    nameController: _nameController,
                    bioController: _bioController,
                    isLoading: isLoading,
                    onSubmit: () => _submit(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
