import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tally_islamic/core/api/api_service.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../../../core/env/app_env.dart';

class StoreStripeService {
  final ApiService _apiService;
  static const _base = 'https://api.stripe.com/v1';

  const StoreStripeService({required ApiService apiService})
    : _apiService = apiService;

  Future<Either<CustomFailure, String>> processPayment({
    required double amount,
    required String currency,
    required String customerId,
  }) async {
    try {
      // 1. Create payment intent
      final response = await _apiService.post(
        url: '$_base/payment_intents',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeSecretKey,
        body: {
          'amount': (amount * 100).round(),
          'currency': currency,
          'customer': customerId,
          'payment_method_types[]': 'card',
          'setup_future_usage': 'off_session',
        },
      );

      final clientSecret = response.data['client_secret'] as String;
      final paymentIntentId = response.data['id'] as String;

      // 2. Create ephemeral key
      final ephemeralKeyResponse = await _apiService.post(
        url: '$_base/ephemeral_keys',
        contentType: Headers.formUrlEncodedContentType,
        token: AppEnv.stripeSecretKey,
        headers: {'Stripe-Version': '2024-12-18.acacia'},
        body: {'customer': customerId},
      );
      final ephemeralKey = ephemeralKeyResponse.data['secret'] as String;

      // 3. Init payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: ephemeralKey,
          merchantDisplayName: 'Tally Islamic',
          customerId: customerId,
          allowsDelayedPaymentMethods: true,
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return right(paymentIntentId);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return left(CustomFailure(errMessage: 'Payment cancelled.'));
      }
      return left(StripeFailure.fromStripeException(e));
    } on DioException catch (e) {
      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
