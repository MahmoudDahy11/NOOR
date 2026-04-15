import 'package:dartz/dartz.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../data/datasource/store_datasource.dart';
import '../../data/service/store_stripe_service.dart';
import '../../domain/entity/ticket_package_entity.dart';
import '../../domain/repo/store_repo.dart';

class StoreRepoImpl implements StoreRepo {
  final StoreDataSource _dataSource;
  final StoreStripeService _stripeService;

  StoreRepoImpl({
    required StoreStripeService stripeService,
    required StoreDataSource dataSource,
  }) : _dataSource = dataSource,
       _stripeService = stripeService;

  @override
  Future<Either<CustomFailure, List<TicketPackageEntity>>> getPackages() async {
    try {
      final packages = await _dataSource.getPackages();
      return right(packages);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, int>> getTicketBalance() async {
    try {
      final balance = await _dataSource.getTicketBalance();
      return right(balance);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> purchasePackage({
    required TicketPackageEntity package,
  }) async {
    try {
      final customerId = await _dataSource.getStripeCustomerId();
      if (customerId == null || customerId.isEmpty) {
        return left(
          CustomFailure(
            errMessage: 'No payment method found. Please add a card.',
          ),
        );
      }

      final paymentResult = await _stripeService.processPayment(
        amount: package.price,
        currency: package.currency,
        customerId: customerId,
      );
      return await paymentResult.fold(
        (f) async => left(f),
        (intentId) => _saveTicketTransactionAndReturn(package, intentId),
      );
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  Future<Either<CustomFailure, void>> _saveTicketTransactionAndReturn(
    TicketPackageEntity package,
    String intentId,
  ) async {
    try {
      await _dataSource.saveTicketTransaction(
        package: package,
        intentId: intentId,
      );
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> refundTickets({
    required String userTicketId,
    required int ticketCount,
  }) async {
    try {
      await _dataSource.refundTickets(
        userTicketId: userTicketId,
        ticketCount: ticketCount,
      );
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
