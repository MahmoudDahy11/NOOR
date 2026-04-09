/*
 * this fior setting up the GetIt service locator
 * it registers services, repole is responsible fsitories, and cubits for dependency injection
 * to use, call getIt<T>() to retrieve an instance of type T
 * for example, getIt<ApiService>() returns the registered ApiService instance
 * make sure to call getItSetup() during app initialization
 */

import 'package:get_it/get_it.dart';

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

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<OtpService>(() => OtpService());

  // Repositories
  getIt.registerLazySingleton<FirebaseAuthRepo>(
    () => FirebaseAuthRepoImplement(getIt<FirebaseService>()),
  );
  getIt.registerLazySingleton<OtpRepository>(
    () => OtpRepositoryImpl(otpService: getIt<OtpService>()),
  );

  // Cubits (Factories)
  getIt.registerFactory(() => SignupCubit(getIt<FirebaseAuthRepo>()));
  getIt.registerFactory(() => LoginCubit(getIt<FirebaseAuthRepo>()));
  getIt.registerFactory(() => SignoutCubit(getIt<FirebaseAuthRepo>()));
  getIt.registerFactory(() => OtpCubit(getIt<OtpRepository>()));
  getIt.registerFactory(() => ForgetPasswordCubit(getIt<FirebaseAuthRepo>()));
  getIt.registerFactory(() => GoogleCubit(getIt<FirebaseAuthRepo>()));
  getIt.registerFactory(() => FacebookCubit(getIt<FirebaseAuthRepo>()));
}
