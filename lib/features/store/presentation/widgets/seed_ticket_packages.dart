import 'package:cloud_firestore/cloud_firestore.dart';

/// Run this ONCE to seed ticket_packages in Firestore.
/// Call from a temp button in dev, then remove.
///
/// Usage:
///   await SeedTicketPackages.run();
class SeedTicketPackages {
  SeedTicketPackages._();

  static Future<void> run() async {
    final col = FirebaseFirestore.instance.collection('ticket_packages');

    final packages = [
      {
        'name': 'Starter',
        'ticketCount': 1,
        'price': 1.0,
        'currency': 'usd',
        'isPopular': false,
      },
      {
        'name': 'Basic',
        'ticketCount': 3,
        'price': 2.0,
        'currency': 'usd',
        'isPopular': false,
      },
      {
        'name': 'Standard',
        'ticketCount': 10,
        'price': 5.0,
        'currency': 'usd',
        'isPopular': false,
      },
      {
        'name': 'Popular',
        'ticketCount': 25,
        'price': 10.0,
        'currency': 'usd',
        'isPopular': true,
      },
      {
        'name': 'Pro',
        'ticketCount': 60,
        'price': 20.0,
        'currency': 'usd',
        'isPopular': false,
      },
      {
        'name': 'Elite',
        'ticketCount': 150,
        'price': 50.0,
        'currency': 'usd',
        'isPopular': false,
      },
      {
        'name': 'Premium',
        'ticketCount': 350,
        'price': 100.0,
        'currency': 'usd',
        'isPopular': false,
      },
      {
        'name': 'Ultimate',
        'ticketCount': 1000,
        'price': 200.0,
        'currency': 'usd',
        'isPopular': false,
      },
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final pkg in packages) {
      batch.set(col.doc(), pkg);
    }
    await batch.commit();
  }
}
