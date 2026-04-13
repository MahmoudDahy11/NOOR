import 'package:cloud_firestore/cloud_firestore.dart';

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
    userId: json['userId'] ?? '',
    packageId: json['packageId'] ?? '',
    ticketCount: json['ticketCount'] ?? 0,
    pricePaid: (json['pricePaid'] as num).toDouble(),
    stripePaymentIntentId: json['stripePaymentIntentId'] ?? '',
    purchasedAt: (json['purchasedAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'packageId': packageId,
    'ticketCount': ticketCount,
    'pricePaid': pricePaid,
    'stripePaymentIntentId': stripePaymentIntentId,
    'purchasedAt': Timestamp.fromDate(purchasedAt),
  };
}
