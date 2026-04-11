/*
 * this fior setting up the GetIt service locator
 * it registers services, repole is responsible fsitories, and cubits for dependency injection
 * to use, call getIt<T>() to retrieve an instance of type T
 * for example, getIt<ApiService>() returns the registered ApiService instance
 * make sure to call getItSetup() during app initialization
 */

import 'package:get_it/get_it.dart';

import '../../features/account_setup/data/repositories/account_setup_repo_impl.dart';
import '../../features/account_setup/domain/repositories/account_setup_repo.dart';
import '../../features/account_setup/presentation/cubit/account_setup_cubit.dart';
import '../../features/add_card/data/repo/add_card_repo_impl.dart';
import '../../features/add_card/domain/repo/add_card_repo.dart';
import '../../features/add_card/presentation/cubit/add_card_cubit.dart';
import '../../features/auth/data/repo/auth_repo_implement.dart';
import '../../features/auth/data/repo/otp_repo_implement.dart';
import '../../features/auth/data/service/firebase_auth.dart';
import '../../features/auth/data/service/otp_service.dart';
import '../../features/auth/domain/repo/auth_repo.dart';
import '../../features/auth/domain/repo/otp_repo.dart';
import '../../features/auth/presentation/cubits/facebook_cubit/facebook_cubit.dart';
import '../../features/auth/presentation/cubits/forget_password_cubit/forget_password_cubit.dart';
import '../../features/auth/presentation/cubits/google_cubit/google_cubit.dart';
import '../../features/auth/presentation/cubits/login_cubit/login_cubit.dart';
import '../../features/auth/presentation/cubits/otp_cubit/otp_cubit.dart';
import '../../features/auth/presentation/cubits/signout_cubit/signout_cubit.dart';
import '../../features/auth/presentation/cubits/signup_cubit/signup_cubit.dart';
import '../../features/profile/data/repos/profile_repo_impl.dart';
import '../../features/profile/domain/repos/profile_repo.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/splash/data/repos/splash_repo_impl.dart';
import '../../features/splash/domain/repos/splash_repo.dart';
import '../../features/splash/presentation/cubits/splash_cubit/splash_cubit.dart';
import '../api/api_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<OtpService>(() => OtpService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  // Repositories
  getIt.registerLazySingleton<FirebaseAuthRepo>(
    () => FirebaseAuthRepoImplement(getIt<FirebaseService>()),
  );
  getIt.registerLazySingleton<OtpRepository>(
    () => OtpRepositoryImpl(otpService: getIt<OtpService>()),
  );
  getIt.registerLazySingleton<AccountSetupRepo>(() => AccountSetupRepoImpl());
  getIt.registerLazySingleton<SplashRepo>(
    () => SplashRepoImpl(accountSetupRepo: getIt<AccountSetupRepo>()),
  );
  getIt.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(firebaseService: getIt<FirebaseService>()),
  );
  getIt.registerLazySingleton<AddCardRepo>(
    () => AddCardRepoImpl(apiService: getIt<ApiService>()),
  );
  // Cubits (Factories)
  getIt.registerFactory(() => SplashCubit(splashRepo: getIt<SplashRepo>()));
  getIt.registerFactory(() => SignupCubit(getIt<FirebaseAuthRepo>()));
  getIt.registerFactory(
    () => LoginCubit(getIt<FirebaseAuthRepo>(), getIt<AccountSetupRepo>()),
  );
  getIt.registerFactory(() => SignoutCubit(getIt<FirebaseAuthRepo>()));
  getIt.registerFactory(() => OtpCubit(getIt<OtpRepository>()));
  getIt.registerFactory(() => ForgetPasswordCubit(getIt<FirebaseAuthRepo>()));
  getIt.registerFactory(
    () => GoogleCubit(getIt<FirebaseAuthRepo>(), getIt<AccountSetupRepo>()),
  );
  getIt.registerFactory(
    () => FacebookCubit(getIt<FirebaseAuthRepo>(), getIt<AccountSetupRepo>()),
  );
  getIt.registerFactory(
    () => AccountSetupCubit(repo: getIt<AccountSetupRepo>()),
  );
  getIt.registerLazySingleton(
    () => ProfileCubit(profileRepo: getIt<ProfileRepo>()),
  );
  getIt.registerFactory(() => AddCardCubit(repo: getIt<AddCardRepo>()));
}
