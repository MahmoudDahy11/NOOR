import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/ticket_package_entity.dart';

import '../cubit/store_cubit.dart';
import 'ticket_balance_header.dart';
import 'ticket_card_widget.dart';

class StoreLoadedBody extends StatefulWidget {
  final StoreState state;
  const StoreLoadedBody({super.key, required this.state});

  @override
  State<StoreLoadedBody> createState() => _StoreLoadedBodyState();
}

class _StoreLoadedBodyState extends State<StoreLoadedBody> {
  final ValueNotifier<String?> _purchasingIdNotifier = ValueNotifier(null);

  @override
  void dispose() {
    _purchasingIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packages = switch (widget.state) {
      StoreLoaded(:final packages) => packages,
      StorePurchaseSuccess(:final packages) => packages,
      _ => const <TicketPackageEntity>[],
    };
    final balance = switch (widget.state) {
      StoreLoaded(:final ticketBalance) => ticketBalance,
      StorePurchaseSuccess(:final ticketBalance) => ticketBalance,
      _ => 0,
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
              (_, i) => ValueListenableBuilder<String?>(
                valueListenable: _purchasingIdNotifier,
                builder: (context, purchasingId, _) {
                  return TicketCardWidget(
                    package: packages[i],
                    isPurchasing: purchasingId == packages[i].id,
                    onTap: () async {
                      _purchasingIdNotifier.value = packages[i].id;
                      await context.read<StoreCubit>().purchasePackage(
                        packages[i],
                      );
                      if (mounted) _purchasingIdNotifier.value = null;
                    },
                  );
                },
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
