import 'package:dartz/dartz.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../entity/stripe_customer_entity.dart';

abstract class AddCardRepo {
  /// Creates a Stripe customer using the restricted key,
  /// saves the customerId to Firestore, returns the entity.
  Future<Either<CustomFailure, StripeCustomerEntity>> createCustomerAndSave();

  /// Attaches the card (from CardField token) to the Stripe customer.
  Future<Either<CustomFailure, void>> attachCard({
    required String customerId,
    required String paymentMethodId,
  });
}
