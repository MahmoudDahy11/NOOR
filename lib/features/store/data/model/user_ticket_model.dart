import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/entity/user_ticket_entity.dart';

class UserTicketModel extends UserTicketEntity {
  const UserTicketModel({
    required super.id,
    required super.userId,
    required super.packageId,
    required super.ticketCount,
    required super.pricePaid,
    required super.stripePaymentIntentId,
    required super.purchasedAt,
  });

  factory UserTicketModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) => UserTicketModel(
    id: docId,
    userId: json[AppKeys.userId] ?? '',
    packageId: json[AppKeys.userTicketPackageId] ?? '',
    ticketCount: json[AppKeys.packageTicketCount] ?? 0,
    pricePaid: (json[AppKeys.userTicketPricePaid] as num).toDouble(),
    stripePaymentIntentId: json[AppKeys.userTicketStripePaymentIntentId] ?? '',
    purchasedAt: (json[AppKeys.userTicketPurchasedAt] as Timestamp).toDate(),
  );

  Map<String, dynamic> toFirestore() => {
    AppKeys.userId: userId,
    AppKeys.userTicketPackageId: packageId,
    AppKeys.packageTicketCount: ticketCount,
    AppKeys.userTicketPricePaid: pricePaid,
    AppKeys.userTicketStripePaymentIntentId: stripePaymentIntentId,
    AppKeys.userTicketPurchasedAt: Timestamp.fromDate(purchasedAt),
  };
}
