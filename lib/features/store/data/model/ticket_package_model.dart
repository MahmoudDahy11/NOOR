import '../../domain/entity/ticket_package_entity.dart';

class TicketPackageModel extends TicketPackageEntity {
  const TicketPackageModel({
    required super.id,
    required super.name,
    required super.ticketCount,
    required super.price,
    required super.currency,
    super.isPopular,
  });

  factory TicketPackageModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) =>
      TicketPackageModel(
        id: docId,
        name: json['name'] ?? '',
        ticketCount: json['ticketCount'] ?? 0,
        price: (json['price'] as num).toDouble(),
        currency: json['currency'] ?? 'usd',
        isPopular: json['isPopular'] ?? false,
      );

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'ticketCount': ticketCount,
        'price': price,
        'currency': currency,
        'isPopular': isPopular,
      };
}
