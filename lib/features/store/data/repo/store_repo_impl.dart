import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../data/model/ticket_package_model.dart';
import '../../data/model/user_ticket_model.dart';
import '../../data/service/store_stripe_service.dart';
import '../../domain/entity/ticket_package_entity.dart';
import '../../domain/repo/store_repo.dart';

class StoreRepoImpl implements StoreRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StoreStripeService _stripeService;

  StoreRepoImpl({
    required StoreStripeService stripeService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _stripeService = stripeService,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  @override
  Future<Either<CustomFailure, List<TicketPackageEntity>>> getPackages() async {
    try {
      final snap = await _firestore
          .collection('ticket_packages')
          .orderBy('price')
          .get();
      return right(
        snap.docs
            .map((d) => TicketPackageModel.fromFirestore(d.data(), d.id))
            .toList(),
      );
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, int>> getTicketBalance() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      return right((doc.data()?['ticket_balance'] ?? 0) as int);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> purchasePackage({
    required TicketPackageEntity package,
    required String customerId,
  }) async {
    try {
      final paymentResult = await _stripeService.processPayment(
        amount: package.price,
        currency: package.currency,
        customerId: customerId,
      );
      return await paymentResult.fold(
        (f) async => left(f),
        (intentId) => _saveTicketTransaction(package, intentId),
      );
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  Future<Either<CustomFailure, void>> _saveTicketTransaction(
    TicketPackageEntity package,
    String intentId,
  ) async {
    try {
      await _firestore.runTransaction((tx) async {
        final userRef = _firestore.collection('users').doc(_uid);
        final ticketRef = _firestore.collection('user_tickets').doc();
        final snap = await tx.get(userRef);
        final balance = (snap.data()?['ticket_balance'] ?? 0) as int;
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
        tx.update(userRef, {'ticket_balance': balance + package.ticketCount});
      });
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> refundTickets({
    required String userTicketId,
    required int ticketCount,
  }) async {
    try {
      await _firestore.runTransaction((tx) async {
        final userRef = _firestore.collection('users').doc(_uid);
        final ticketRef = _firestore
            .collection('user_tickets')
            .doc(userTicketId);
        final snap = await tx.get(userRef);
        final balance = (snap.data()?['ticket_balance'] ?? 0) as int;
        tx.update(ticketRef, {'refunded': true});
        tx.update(userRef, {
          'ticket_balance': (balance - ticketCount).clamp(
            0,
            double.maxFinite.toInt(),
          ),
        });
      });
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
