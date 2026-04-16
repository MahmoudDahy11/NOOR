import '../../../../core/constants/app_keys.dart';
import '../../domain/entity/stripe_customer_entity.dart';

class StripeCustomerModel extends StripeCustomerEntity {
  const StripeCustomerModel({required super.customerId, required super.email});

  factory StripeCustomerModel.fromJson(Map<String, dynamic> json) =>
      StripeCustomerModel(
        customerId: json[AppKeys.stripeId] ?? '',
        email: json[AppKeys.email] ?? '',
      );

  Map<String, dynamic> toFirestore() => {
    AppKeys.stripeCustomerId: customerId,
    AppKeys.stripeEmail: email,
    AppKeys.userCardAddedAt: DateTime.now().toIso8601String(),
  };
}
