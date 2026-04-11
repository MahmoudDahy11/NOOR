import '../../domain/entity/stripe_customer_entity.dart';

class StripeCustomerModel extends StripeCustomerEntity {
  const StripeCustomerModel({required super.customerId, required super.email});

  factory StripeCustomerModel.fromJson(Map<String, dynamic> json) =>
      StripeCustomerModel(
        customerId: json['id'] ?? '',
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toFirestore() => {
    'stripeCustomerId': customerId,
    'stripeEmail': email,
    'cardAddedAt': DateTime.now().toIso8601String(),
  };
}
