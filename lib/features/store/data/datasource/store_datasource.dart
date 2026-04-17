import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../../data/model/ticket_package_model.dart';
import '../../data/model/user_ticket_model.dart';
import '../../domain/entity/ticket_package_entity.dart';

/// Store Data Source - Firestore operations for ticket purchases
class StoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StoreDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String get _uid => _auth.currentUser!.uid;

  /// Get all ticket packages
  Future<List<TicketPackageEntity>> getPackages() async {
    try {
      final snap = await _firestore
          .collection(AppKeys.ticketPackagesCollection)
          .orderBy(AppKeys.packagePrice)
          .get();
      return snap.docs
          .map((d) => TicketPackageModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get packages: $e');
    }
  }

  /// Get current user's ticket balance
  Future<int> getTicketBalance() async {
    try {
      final doc = await _firestore
          .collection(AppKeys.usersCollection)
          .doc(_uid)
          .get();
      return (doc.data()?[AppKeys.ticketBalance] ?? 0) as int;
    } catch (e) {
      throw Exception('Failed to get ticket balance: $e');
    }
  }

  /// Get stripe customer ID
  Future<String?> getStripeCustomerId() async {
    try {
      final doc = await _firestore
          .collection(AppKeys.usersCollection)
          .doc(_uid)
          .get();
      return doc.data()?[AppKeys.stripeCustomerId] as String?;
    } catch (e) {
      throw Exception('Failed to get customer id: $e');
    }
  }

  /// Save ticket transaction after successful payment
  Future<void> saveTicketTransaction({
    required TicketPackageEntity package,
    required String intentId,
  }) async {
    try {
      await _firestore.runTransaction((tx) async {
        final userRef = _firestore
            .collection(AppKeys.usersCollection)
            .doc(_uid);
        final ticketRef = _firestore
            .collection(AppKeys.userTicketsCollection)
            .doc();
        final snap = await tx.get(userRef);
        final balance = (snap.data()?[AppKeys.ticketBalance] ?? 0) as int;

        tx.set(
          ticketRef,
          UserTicketModel(
            id: ticketRef.id,
            userId: _uid,
            packageId: package.id,
            ticketCount: package.ticketCount,
            pricePaid: package.price,
            stripePaymentIntentId: intentId,
            purchasedAt: DateTime.now(),
          ).toFirestore(),
        );

        tx.update(userRef, {
          AppKeys.ticketBalance: balance + package.ticketCount,
        });
      });
    } catch (e) {
      throw Exception('Failed to save ticket transaction: $e');
    }
  }

  /// Refund tickets for a user
  Future<void> refundTickets({
    required String userTicketId,
    required int ticketCount,
  }) async {
    try {
      await _firestore.runTransaction((tx) async {
        final userRef = _firestore
            .collection(AppKeys.usersCollection)
            .doc(_uid);
        final ticketRef = _firestore
            .collection(AppKeys.userTicketsCollection)
            .doc(userTicketId);
        final snap = await tx.get(userRef);
        final balance = (snap.data()?[AppKeys.ticketBalance] ?? 0) as int;

        tx.update(ticketRef, {AppKeys.userTicketRefunded: true});
        tx.update(userRef, {
          AppKeys.ticketBalance: (balance - ticketCount).clamp(
            0,
            double.maxFinite.toInt(),
          ),
        });
      });
    } catch (e) {
      throw Exception('Failed to refund tickets: $e');
    }
  }
}
