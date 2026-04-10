import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract class SplashRepo {
  Future<Either<CustomFailure, String>> checkInitialNavigation();
}
