import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../domain/repo/store_repo.dart';
import '../cubit/store_cubit.dart';
import '../widgets/store_loaded_body.dart';
import '../widgets/ticket_balance_header.dart';
import '../widgets/ticket_card_shimmer.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoreCubit(repo: getIt<StoreRepo>())..loadStore(),
      child: const _StoreView(),
    );
  }
}

class _StoreView extends StatelessWidget {
  const _StoreView();

  void _handleState(BuildContext context, StoreState state) {
    if (state is StorePurchaseSuccess) {
      log('Purchase successful: ${state.ticketBalance} tickets added');
      showSnakBar(context, 'Tickets added to your balance! 🎉');
    } else if (state is StoreFailure) {
      log('Purchase failed: ${state.message}');
      showSnakBar(context, state.message, isError: true);
      context.read<StoreCubit>().loadStore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoreCubit, StoreState>(
      listener: _handleState,
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.background,
        body: switch (state) {
          StoreLoading() => const _StoreShimmerBody(),
          StoreLoaded() ||
          StorePurchasing() ||
          StorePurchaseSuccess() => StoreLoadedBody(state: state),
          StoreFailure() => _StoreErrorBody(
            message: state.message,
            onRetry: () => context.read<StoreCubit>().loadStore(),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

/// Shimmer shown ONLY during loading — not on real cards
class _StoreShimmerBody extends StatelessWidget {
  const _StoreShimmerBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: TicketBalanceHeader(balance: 0)),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, _) => const TicketCardShimmer(),
              childCount: 6,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _StoreErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.error,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
