import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failure.dart';
import '../../../account_setup/domain/repositories/account_setup_repo.dart';
import '../../../add_card/domain/repo/add_card_repo.dart';
import '../../../auth/data/service/local_storage.dart';
import '../../domain/repos/splash_repo.dart';

class SplashRepoImpl implements SplashRepo {
  final AccountSetupRepo _accountSetupRepo;
  final AddCardRepo _addCardRepo;

  SplashRepoImpl({
    required AccountSetupRepo accountSetupRepo,
    required AddCardRepo addCardRepo,
  }) : _accountSetupRepo = accountSetupRepo,
       _addCardRepo = addCardRepo;

  @override
  Future<Either<CustomFailure, String>> checkInitialNavigation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = LocalStorageService.isLoggedIn();

      if (loggedIn && user != null) {
        final result = await _accountSetupRepo.hasUserProfile(user.uid);

        return await result.fold(
          (failure) async => Left(failure),
          (profileExists) async {
            if (profileExists) {
              final cardResult = await _addCardRepo.hasCard(user.uid);
              return cardResult.fold(
                (failure) => Left(failure),
                (hasCard) {
                  if (hasCard) {
                    return const Right('home');
                  } else {
                    return const Right('add_card');
                  }
                },
              );
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
