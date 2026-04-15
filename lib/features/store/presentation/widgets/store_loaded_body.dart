import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/ticket_package_entity.dart';

import '../cubit/store_cubit.dart';
import 'ticket_balance_header.dart';
import 'ticket_card_widget.dart';

class StoreLoadedBody extends StatelessWidget {
  final StoreState state;
  const StoreLoadedBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final packages = switch (state) {
      StoreLoaded(:final packages) => packages,
      StorePurchasing(:final packages) => packages,
      StorePurchaseSuccess(:final packages) => packages,
      _ => const <TicketPackageEntity>[],
    };
    final balance = switch (state) {
      StoreLoaded(:final ticketBalance) => ticketBalance,
      StorePurchasing(:final ticketBalance) => ticketBalance,
      StorePurchaseSuccess(:final ticketBalance) => ticketBalance,
      _ => 0,
    };
    final purchasingId = switch (state) {
      StorePurchasing(:final purchasingPackageId) => purchasingPackageId,
      _ => null,
    };

    final width = MediaQuery.sizeOf(context).width;
    int crossAxisCount;
    double childAspectRatio;

    if (width > 600) {
      crossAxisCount = 3;
      childAspectRatio = 1.5; // Tablet optimization
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.75; // Mobile standard
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: TicketBalanceHeader(balance: balance)),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => TicketCardWidget(
                package: packages[i],
                isPurchasing: purchasingId == packages[i].id,
                onTap: () =>
                    context.read<StoreCubit>().purchasePackage(packages[i]),
              ),
              childCount: packages.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
          ),
        ),
      ],
    );
  }
}
