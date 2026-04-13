class TicketPackageEntity {
  final String id;
  final String name;
  final int ticketCount;
  final double price;
  final String currency;
  final bool isPopular;

  const TicketPackageEntity({
    required this.id,
    required this.name,
    required this.ticketCount,
    required this.price,
    required this.currency,
    this.isPopular = false,
  });
}
