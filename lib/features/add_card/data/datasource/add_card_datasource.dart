import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tally_islamic/core/api/api_service.dart';

import '../../../../core/env/app_env.dart';
import '../model/stripe_customer_model.dart';

/// AddCard Data Source - Stripe and Firestore operations
class AddCardDataSource {
  final ApiService _apiService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _stripeBase = 'https://api.stripe.com/v1';

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
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final existingId = doc.data()?['stripeCustomerId'] as String?;

      if (existingId != null && existingId.isNotEmpty) {
        return StripeCustomerModel(
          customerId: existingId,
          email: user.email ?? '',
        );
      }

      // Create new Stripe customer using restricted key
      final response = await _apiService.post(
        url: '$_stripeBase/customers',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeRestrictedKey,
        body: {
          'email': user.email,
          'name': doc.data()?['displayName'] ?? '',
          'metadata': {'firebaseUid': user.uid},
        },
      );

      final model = StripeCustomerModel.fromJson(response.data);

      // Save to Firestore
      await _firestore
          .collection('users')
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
        url: '$_stripeBase/payment_methods/$paymentMethodId/attach',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeRestrictedKey,
        body: {'customer': customerId},
      );

      // Set as default payment method
      await _apiService.post(
        url: '$_stripeBase/customers/$customerId',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeRestrictedKey,
        body: {
          'invoice_settings': {'default_payment_method': paymentMethodId},
        },
      );

      // Save paymentMethodId to Firestore
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({
          'defaultPaymentMethodId': paymentMethodId,
          'hasCard': true,
        });
      }
    } catch (e) {
      throw Exception('Failed to attach card: $e');
    }
  }

  /// Check if user has a card saved
  Future<bool> hasCard(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['hasCard'] == true;
    } catch (e) {
      throw Exception('Failed to check card: $e');
    }
  }
}
