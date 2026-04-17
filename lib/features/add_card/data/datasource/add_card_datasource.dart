import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tally_islamic/core/api/api_service.dart';
import 'package:tally_islamic/core/constants/app_keys.dart';
import 'package:tally_islamic/core/env/app_env.dart';
import '../model/stripe_customer_model.dart';

/// AddCard Data Source - Stripe and Firestore operations
class AddCardDataSource {
  final ApiService _apiService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AddCardDataSource({
    required ApiService apiService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _apiService = apiService,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  /// Create Stripe customer and save to Firestore
  Future<StripeCustomerModel> createCustomerAndSave() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated.');
      }

      // Check if customer already exists in Firestore
      final doc = await _firestore
          .collection(AppKeys.usersCollection)
          .doc(user.uid)
          .get();
      final existingId = doc.data()?[AppKeys.stripeCustomerId] as String?;

      if (existingId != null && existingId.isNotEmpty) {
        return StripeCustomerModel(
          customerId: existingId,
          email: user.email ?? '',
        );
      }

      // Create new Stripe customer using restricted key
      final response = await _apiService.post(
        url: '${AppKeys.stripeBaseUrl}/customers',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeRestrictedKey,
        body: {
          AppKeys.email: user.email,
          AppKeys.name: doc.data()?[AppKeys.displayName] ?? '',
          'metadata': {AppKeys.stripeMetadataFirebaseUid: user.uid},
        },
      );

      final model = StripeCustomerModel.fromJson(response.data);

      // Save to Firestore
      await _firestore
          .collection(AppKeys.usersCollection)
          .doc(user.uid)
          .update(model.toFirestore());

      return model;
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  /// Attach payment method to customer
  Future<void> attachCard({
    required String customerId,
    required String paymentMethodId,
  }) async {
    try {
      // Attach payment method to customer
      await _apiService.post(
        url: '${AppKeys.stripeBaseUrl}/payment_methods/$paymentMethodId/attach',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeRestrictedKey,
        body: {AppKeys.stripeCustomer: customerId},
      );

      // Set as default payment method
      await _apiService.post(
        url: '${AppKeys.stripeBaseUrl}/customers/$customerId',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeRestrictedKey,
        body: {
          AppKeys.stripeInvoiceSettings: {
            AppKeys.stripeDefaultPaymentMethod: paymentMethodId,
          },
        },
      );

      // Save paymentMethodId to Firestore
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection(AppKeys.usersCollection).doc(uid).update({
          AppKeys.defaultPaymentMethodId: paymentMethodId,
          AppKeys.hasCard: true,
        });
      }
    } catch (e) {
      throw Exception('Failed to attach card: $e');
    }
  }

  /// Check if user has a card saved
  Future<bool> hasCard(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppKeys.usersCollection)
          .doc(uid)
          .get();
      return doc.data()?[AppKeys.hasCard] == true;
    } catch (e) {
      throw Exception('Failed to check card: $e');
    }
  }
}
