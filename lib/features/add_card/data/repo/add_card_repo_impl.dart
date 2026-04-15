import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../domain/entity/stripe_customer_entity.dart';
import '../../domain/repo/add_card_repo.dart';
import '../datasource/add_card_datasource.dart';

class AddCardRepoImpl implements AddCardRepo {
  final AddCardDataSource? _dataSource;

  AddCardRepoImpl({AddCardDataSource? dataSource}) : _dataSource = dataSource;

  @override
  Future<Either<CustomFailure, StripeCustomerEntity>>
  createCustomerAndSave() async {
    try {
      final model = await _dataSource!.createCustomerAndSave();
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
      await _dataSource!.attachCard(
        customerId: customerId,
        paymentMethodId: paymentMethodId,
      );
      return right(null);
    } on DioException catch (e) {
      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, bool>> hasCard(String uid) async {
    try {
      final hasCard = await _dataSource!.hasCard(uid);
      return right(hasCard);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }
}
