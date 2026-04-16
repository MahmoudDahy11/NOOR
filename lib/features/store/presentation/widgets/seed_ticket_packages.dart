import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_keys.dart';

/// Run this ONCE to seed ticket_packages in Firestore.
/// Call from a temp button in dev, then remove.
///
/// Usage:
///   await SeedTicketPackages.run();
class SeedTicketPackages {
  SeedTicketPackages._();

  static Future<void> run() async {
    final col = FirebaseFirestore.instance.collection(AppKeys.ticketPackagesCollection);

    final packages = [
      {
        AppKeys.name: 'Starter',
        AppKeys.packageTicketCount: 1,
        AppKeys.packagePrice: 1.0,
        AppKeys.packageCurrency: 'usd',
        AppKeys.packageIsPopular: false,
      },
      {
        AppKeys.name: 'Basic',
        AppKeys.packageTicketCount: 3,
        AppKeys.packagePrice: 2.0,
        AppKeys.packageCurrency: 'usd',
        AppKeys.packageIsPopular: false,
      },
      {
        AppKeys.name: 'Standard',
        AppKeys.packageTicketCount: 10,
        AppKeys.packagePrice: 5.0,
        AppKeys.packageCurrency: 'usd',
        AppKeys.packageIsPopular: false,
      },
      {
        AppKeys.name: 'Popular',
        AppKeys.packageTicketCount: 25,
        AppKeys.packagePrice: 10.0,
        AppKeys.packageCurrency: 'usd',
        AppKeys.packageIsPopular: true,
      },
      {
        AppKeys.name: 'Pro',
        AppKeys.packageTicketCount: 60,
        AppKeys.packagePrice: 20.0,
        AppKeys.packageCurrency: 'usd',
        AppKeys.packageIsPopular: false,
      },
      {
        AppKeys.name: 'Elite',
        AppKeys.packageTicketCount: 150,
        AppKeys.packagePrice: 50.0,
        AppKeys.packageCurrency: 'usd',
        AppKeys.packageIsPopular: false,
      },
      {
        AppKeys.name: 'Premium',
        AppKeys.packageTicketCount: 350,
        AppKeys.packagePrice: 100.0,
        AppKeys.packageCurrency: 'usd',
        AppKeys.packageIsPopular: false,
      },
      {
        AppKeys.name: 'Ultimate',
        AppKeys.packageTicketCount: 1000,
        AppKeys.packagePrice: 200.0,
        AppKeys.packageCurrency: 'usd',
        AppKeys.packageIsPopular: false,
      },
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final pkg in packages) {
      batch.set(col.doc(), pkg);
    }
    await batch.commit();
  }
}
