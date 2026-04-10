import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failure.dart';
import '../../../account_setup/domain/repositories/account_setup_repo.dart';
import '../../../auth/data/service/local_storage.dart';
import '../../domain/repos/splash_repo.dart';

class SplashRepoImpl implements SplashRepo {
  final AccountSetupRepo _accountSetupRepo;

  SplashRepoImpl({required AccountSetupRepo accountSetupRepo})
      : _accountSetupRepo = accountSetupRepo;

  @override
  Future<Either<CustomFailure, String>> checkInitialNavigation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = LocalStorageService.isLoggedIn();

      if (loggedIn && user != null) {
        final result = await _accountSetupRepo.hasUserProfile(user.uid);

        return result.fold(
          (failure) => Left(failure),
          (profileExists) {
            if (profileExists) {
              return const Right('home');
            } else {
              return const Right('account_setup');
            }
          },
        );
      } else {
        return const Right('onboarding');
      }
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }
}
