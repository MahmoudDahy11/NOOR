import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repo/add_card_repo.dart';
import '../cubit/add_card_cubit.dart';
import '../widgets/add_card_form_widget.dart';
import '../widgets/add_card_header_widget.dart';
import '../widgets/add_card_submit_button.dart';
import '../widgets/add_card_success_sheet.dart';
import '../widgets/card_brand_icons_widget.dart';
import '../widgets/card_visual_widget.dart';

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCardCubit(repo: getIt<AddCardRepo>())..initCustomer(),
      child: const _AddCardView(),
    );
  }
}

class _AddCardView extends StatelessWidget {
  const _AddCardView();

  void _handleState(BuildContext context, AddCardState state) {
    if (state is AddCardSuccess) {
      log('AddCardSuccess');
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (_) => AddCardSuccessSheet(
          onContinue: () {
            Navigator.pop(context);
            context.go(AppRouter.homeRoute);
          },
        ),
      );
    } else if (state is AddCardFailure) {
      log('AddCardFailure');
      showSnakBar(context, state.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCardCubit, AddCardState>(
      listener: _handleState,
      builder: (context, state) {
        final isLoading =
            state is AddCardSaving || state is AddCardCreatingCustomer;
        final customerId = state is AddCardReadyToSubmit
            ? state.customerId
            : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              const AddCardHeaderWidget(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const CardVisualWidget(),
                    const SizedBox(height: 32),
                    AddCardFormWidget(state: state),
                    const SizedBox(height: 24),
                    const CardBrandIconsWidget(),
                    const SizedBox(height: 40),
                    AddCardSubmitButton(
                      isLoading: isLoading,
                      customerId: customerId,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppRouter.homeRoute),
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(
                              alpha: .7,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
