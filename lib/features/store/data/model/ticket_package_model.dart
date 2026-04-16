import '../../../../core/constants/app_keys.dart';
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
        name: json[AppKeys.name] ?? '',
        ticketCount: json[AppKeys.packageTicketCount] ?? 0,
        price: (json[AppKeys.packagePrice] as num).toDouble(),
        currency: json[AppKeys.packageCurrency] ?? 'usd',
        isPopular: json[AppKeys.packageIsPopular] ?? false,
      );

  Map<String, dynamic> toFirestore() => {
        AppKeys.name: name,
        AppKeys.packageTicketCount: ticketCount,
        AppKeys.packagePrice: price,
        AppKeys.packageCurrency: currency,
        AppKeys.packageIsPopular: isPopular,
      };
}
