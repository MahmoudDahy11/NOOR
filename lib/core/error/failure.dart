import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/*
 * CustomException class
 * represents a custom exception with an error message
 */
class CustomFailure {
  final String errMessage;
  CustomFailure({required this.errMessage});
}

/*
 * ServerFailure class
 * extends CustomFailure
 * includes factory constructors to create instances from DioException and HTTP response
 */

class ServerFailure extends CustomFailure {
  ServerFailure({required super.errMessage});
  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(errMessage: 'Connction time outTime with api');
      case DioExceptionType.sendTimeout:
        return ServerFailure(errMessage: 'Send messege fail with api');
      case DioExceptionType.receiveTimeout:
        return ServerFailure(errMessage: 'Receive messege fail with api');
      case DioExceptionType.badCertificate:
        return ServerFailure(errMessage: 'Bad certificate received');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          dioException.response!.statusCode!,
          dioException.response!.data,
        );
      case DioExceptionType.cancel:
        return ServerFailure(
          errMessage: 'the reust was cancelled ,please try again!',
        );
      case DioExceptionType.connectionError:
        return ServerFailure(
          errMessage: 'the internet connection fail,please try again!',
        );
      case DioExceptionType.unknown:
        return ServerFailure(errMessage: 'Unexpected error ,please try again!');
      // ignore: unreachable_switch_default
      default:
        return ServerFailure(
          errMessage: 'Oops ther was an error ,please try again!',
        );
    }
  }
  factory ServerFailure.fromResponse(
    int satatusCode,
    Map<String, dynamic> responsData,
  ) {
    if (satatusCode == 400 || satatusCode == 401 || satatusCode == 403) {
      return ServerFailure(errMessage: responsData['error']['message']);
    } else if (satatusCode == 404) {
      return ServerFailure(
        errMessage: 'You requst not found,please try later!',
      );
    } else if (satatusCode == 500) {
      return ServerFailure(
        errMessage: 'the Server has an error ,please try later!',
      );
    } else {
      return ServerFailure(errMessage: 'Unexpected error ,please try again!');
    }
  }
}

/*
 * StripeFailure class
 * extends CustomFailure
 * includes factory constructors to handle different StripeException cases
 */
class StripeFailure extends CustomFailure {
  StripeFailure({required super.errMessage});

  factory StripeFailure.fromStripeException(StripeException stripeException) {
    final error = stripeException.error;

    switch (error.code) {
      case FailureCode.Canceled:
        return StripeFailure(
          errMessage: 'The payment process was canceled by the user.',
        );
      case FailureCode.Failed:
        return StripeFailure(
          errMessage: 'The payment process failed. Please try again.',
        );
      case FailureCode.Timeout:
        return StripeFailure(
          errMessage: 'Connection to Stripe timed out. Please try again.',
        );
      }
  }

  factory StripeFailure.fromGenericError(dynamic error) {
    return StripeFailure(errMessage: error.toString());
  }
}
