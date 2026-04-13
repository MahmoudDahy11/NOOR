class UserTicketEntity {
  final String id;
  final String userId;
  final String packageId;
  final int ticketCount;
  final double pricePaid;
  final String stripePaymentIntentId;
  final DateTime purchasedAt;

  const UserTicketEntity({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.ticketCount,
    required this.pricePaid,
    required this.stripePaymentIntentId,
    required this.purchasedAt,
  });
}
