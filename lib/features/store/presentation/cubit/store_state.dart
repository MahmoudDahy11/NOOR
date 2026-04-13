part of 'store_cubit.dart';

@immutable
sealed class StoreState {
  const StoreState();
}

final class StoreInitial extends StoreState {
  const StoreInitial();
}

final class StoreLoading extends StoreState {
  const StoreLoading();
}

final class StoreLoaded extends StoreState {
  final List<TicketPackageEntity> packages;
  final int ticketBalance;

  const StoreLoaded({required this.packages, required this.ticketBalance});
}

final class StorePurchasing extends StoreState {
  final List<TicketPackageEntity> packages;
  final int ticketBalance;
  final String purchasingPackageId;

  const StorePurchasing({
    required this.packages,
    required this.ticketBalance,
    required this.purchasingPackageId,
  });
}

final class StorePurchaseSuccess extends StoreState {
  final List<TicketPackageEntity> packages;
  final int ticketBalance;

  const StorePurchaseSuccess({
    required this.packages,
    required this.ticketBalance,
  });
}

final class StoreFailure extends StoreState {
  final String message;
  const StoreFailure(this.message);
}
