import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract class SplashRepo {
  /*
   * Determines the initial navigation target for the splash screen
   * Returns Either a CustomFailure or a String indicating the navigation target
   * The navigation target can be 'home', 'account_setup', or 'onboarding'
   * This method interacts with local storage or other data sources to make the decision
   */
  Future<Either<CustomFailure, String>> checkInitialNavigation();
}
