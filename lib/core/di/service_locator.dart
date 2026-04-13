/*
 * this fior setting up the GetIt service locator
 * it registers services, repositories, and cubits for dependency injection
 * to use, call getIt<T>() to retrieve an instance of type T
 * for example, getIt<ApiService>() returns the registered ApiService instance
 * make sure to call getItSetup() during app initialization
 */

import 'package:get_it/get_it.dart';

import '../../features/account_setup/data/repositories/account_setup_repo_impl.dart';
import '../../features/account_setup/domain/repositories/account_setup_repo.dart';
import '../../features/add_card/data/repo/add_card_repo_impl.dart';
import '../../features/add_card/domain/repo/add_card_repo.dart';
import '../../features/auth/data/repo/auth_repo_implement.dart';
import '../../features/auth/data/repo/otp_repo_implement.dart';
import '../../features/auth/data/service/firebase_auth.dart';
import '../../features/auth/data/service/otp_service.dart';
import '../../features/auth/domain/repo/auth_repo.dart';
import '../../features/auth/domain/repo/otp_repo.dart';
import '../../features/profile/data/repos/profile_repo_impl.dart';
import '../../features/profile/domain/repos/profile_repo.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/splash/data/repos/splash_repo_impl.dart';
import '../../features/splash/domain/repos/splash_repo.dart';
import '../../features/store/data/repo/store_repo_impl.dart';
import '../../features/store/data/service/store_stripe_service.dart';
import '../../features/store/domain/repo/store_repo.dart';
import '../api/api_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<OtpService>(() => OtpService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<StoreStripeService>(
    () => StoreStripeService(apiService: getIt<ApiService>()),
  );
  // Repositories
  getIt.registerLazySingleton<FirebaseAuthRepo>(
    () => FirebaseAuthRepoImplement(getIt<FirebaseService>()),
  );
  getIt.registerLazySingleton<OtpRepository>(
    () => OtpRepositoryImpl(otpService: getIt<OtpService>()),
  );
  getIt.registerLazySingleton<AccountSetupRepo>(() => AccountSetupRepoImpl());
  getIt.registerLazySingleton<SplashRepo>(
    () => SplashRepoImpl(
      accountSetupRepo: getIt<AccountSetupRepo>(),
      addCardRepo: getIt<AddCardRepo>(),
    ),
  );
  getIt.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(firebaseService: getIt<FirebaseService>()),
  );
  getIt.registerLazySingleton<AddCardRepo>(
    () => AddCardRepoImpl(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<StoreRepo>(
    () => StoreRepoImpl(stripeService: getIt<StoreStripeService>()),
  );

  // Cubits
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(profileRepo: getIt<ProfileRepo>()),
  );
}
