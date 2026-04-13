import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../domain/entity/ticket_package_entity.dart';
import '../../domain/repo/store_repo.dart';

part 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  final StoreRepo _repo;

  StoreCubit({required StoreRepo repo})
    : _repo = repo,
      super(const StoreInitial());

  Future<void> loadStore() async {
    emit(const StoreLoading());
    if (isClosed) return;

    final packagesResult = await _repo.getPackages();
    final balanceResult = await _repo.getTicketBalance();

    if (packagesResult.isLeft() || balanceResult.isLeft()) {
      final error =
          packagesResult.fold((f) => f.errMessage, (_) => '') +
          balanceResult.fold((f) => f.errMessage, (_) => '');
      emit(StoreFailure(error));
      return;
    }

    final packages = packagesResult.getOrElse(() => <TicketPackageEntity>[]);
    final balance = balanceResult.getOrElse(() => 0);

    emit(StoreLoaded(packages: packages, ticketBalance: balance));
  }

  Future<void> purchasePackage(TicketPackageEntity package) async {
    final current = state;
    if (current is! StoreLoaded && current is! StorePurchaseSuccess) return;

    final currentPackages = current is StoreLoaded
        ? current.packages
        : (current as StorePurchaseSuccess).packages;
    final currentBalance = current is StoreLoaded
        ? current.ticketBalance
        : (current as StorePurchaseSuccess).ticketBalance;

    // Get customerId from Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(const StoreFailure('User not authenticated.'));
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final customerId = userDoc.data()?['stripeCustomerId'] as String?;

    if (customerId == null || customerId.isEmpty) {
      emit(const StoreFailure('No payment method found. Please add a card.'));
      return;
    }

    emit(
      StorePurchasing(
        packages: currentPackages,
        ticketBalance: currentBalance,
        purchasingPackageId: package.id,
      ),
    );

    log('[Store] Purchasing package: ${package.name} - \$${package.price}');

    final result = await _repo.purchasePackage(
      package: package,
      customerId: customerId,
    );

    result.fold(
      (failure) {
        log('[Store] Purchase failed: ${failure.errMessage}');
        emit(StoreFailure(failure.errMessage));
      },
      (_) {
        log('[Store] Purchase success: ${package.ticketCount} tickets added');
        final newBalance = currentBalance + package.ticketCount;
        emit(
          StorePurchaseSuccess(
            packages: currentPackages,
            ticketBalance: newBalance,
          ),
        );
      },
    );
  }
}
