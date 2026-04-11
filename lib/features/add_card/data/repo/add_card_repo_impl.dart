import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tally_islamic/core/api/api_service.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../../../core/env/app_env.dart';
import '../../domain/entity/stripe_customer_entity.dart';
import '../../domain/repo/add_card_repo.dart';
import '../model/stripe_customer_model.dart';

class AddCardRepoImpl implements AddCardRepo {
  final ApiService _apiService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _stripeBase = 'https://api.stripe.com/v1';

  AddCardRepoImpl({
    required ApiService apiService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _apiService = apiService,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Either<CustomFailure, StripeCustomerEntity>>
  createCustomerAndSave() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return left(CustomFailure(errMessage: 'User not authenticated.'));
      }

      // Check if customer already exists in Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final existingId = doc.data()?['stripeCustomerId'] as String?;

      if (existingId != null && existingId.isNotEmpty) {
        return right(
          StripeCustomerModel(customerId: existingId, email: user.email ?? ''),
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

      return right(model);
    } on DioException catch (e) {
      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> attachCard({
    required String customerId,
    required String paymentMethodId,
  }) async {
    try {
      // Attach payment method to customer
      await _apiService.post(
        url: '$_stripeBase/payment_methods/$paymentMethodId/attach',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeSecretKey,
        body: {'customer': customerId},
      );

      // Set as default payment method
      await _apiService.post(
        url: '$_stripeBase/customers/$customerId',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeSecretKey,
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

      return right(null);
    } on DioException catch (e) {
      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
