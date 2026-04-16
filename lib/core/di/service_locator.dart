/*
 * this fior setting up the GetIt service locator
 * it registers services, repositories, and cubits for dependency injection
 * to use, call getIt<T>() to retrieve an instance of type T
 * for example, getIt<ApiService>() returns the registered ApiService instance
 * make sure to call getItSetup() during app initialization
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/account_setup/data/datasource/account_setup_datasource.dart';
import '../../features/account_setup/data/repositories/account_setup_repo_impl.dart';
import '../../features/account_setup/domain/repositories/account_setup_repo.dart';
import '../../features/add_card/data/datasource/add_card_datasource.dart';
import '../../features/add_card/data/repo/add_card_repo_impl.dart';
import '../../features/add_card/domain/repo/add_card_repo.dart';
import '../../features/auth/data/repo/auth_repo_implement.dart';
import '../../features/auth/data/repo/otp_repo_implement.dart';
import '../../features/auth/data/service/firebase_auth.dart';
import '../../features/auth/data/service/otp_service.dart';
import '../../features/auth/domain/repo/auth_repo.dart';
import '../../features/auth/domain/repo/otp_repo.dart';
import '../../features/create_room/data/datasource/create_room_datasource.dart';
import '../../features/create_room/data/repositories/create_room_repo_impl.dart';
import '../../features/create_room/domain/repositories/create_room_repo.dart';
import '../../features/feed/data/repositories/feed_repo_impl.dart';
import '../../features/feed/domain/repositories/feed_repo.dart';
import '../../features/live_room/data/datasource/live_room_datasource.dart';
import '../../features/live_room/data/repositories/live_room_repo_impl.dart';
import '../../features/live_room/domain/repositories/live_room_repo.dart';
import '../../features/profile/data/datasource/profile_datasource.dart';
import '../../features/profile/data/repos/profile_repo_impl.dart';
import '../../features/profile/domain/repos/profile_repo.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/splash/data/repos/splash_repo_impl.dart';
import '../../features/splash/domain/repos/splash_repo.dart';
import '../../features/store/data/datasource/store_datasource.dart';
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

  // Data Sources
  getIt.registerLazySingleton<AccountSetupDataSource>(
    () => AccountSetupDataSource(),
  );
  getIt.registerLazySingleton<AddCardDataSource>(
    () => AddCardDataSource(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ProfileDataSource>(() => ProfileDataSource());
  getIt.registerLazySingleton<CreateRoomDataSource>(
    () => CreateRoomDataSource(),
  );
  getIt.registerLazySingleton<StoreDataSource>(
    () => StoreDataSource(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );

  // Repositories
  getIt.registerLazySingleton<FirebaseAuthRepo>(
    () => FirebaseAuthRepoImplement(getIt<FirebaseService>()),
  );
  getIt.registerLazySingleton<OtpRepository>(
    () => OtpRepositoryImpl(otpService: getIt<OtpService>()),
  );
  getIt.registerLazySingleton<AccountSetupRepo>(
    () => AccountSetupRepoImpl(dataSource: getIt<AccountSetupDataSource>()),
  );
  getIt.registerLazySingleton<SplashRepo>(
    () => SplashRepoImpl(
      accountSetupRepo: getIt<AccountSetupRepo>(),
      addCardRepo: getIt<AddCardRepo>(),
    ),
  );
  getIt.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(dataSource: getIt<ProfileDataSource>()),
  );
  getIt.registerLazySingleton<AddCardRepo>(
    () => AddCardRepoImpl(dataSource: getIt<AddCardDataSource>()),
  );
  getIt.registerLazySingleton<StoreRepo>(
    () => StoreRepoImpl(
      stripeService: getIt<StoreStripeService>(),
      dataSource: getIt<StoreDataSource>(),
    ),
  );
  getIt.registerLazySingleton<CreateRoomRepo>(
    () => CreateRoomRepoImpl(dataSource: getIt<CreateRoomDataSource>()),
  );
  getIt.registerLazySingleton<FeedRepo>(() => FeedRepoImpl());
  getIt.registerLazySingleton<LiveRoomDataSource>(
    () => LiveRoomDataSource(),
  );
  getIt.registerLazySingleton<LiveRoomRepo>(
    () => LiveRoomRepoImpl(dataSource: getIt<LiveRoomDataSource>()),
  );
  // Cubits
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      profileRepo: getIt<ProfileRepo>(),
      createRoomRepo: getIt<CreateRoomRepo>(),
    ),
  );
}
