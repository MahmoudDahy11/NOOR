import 'dart:developer';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tally_islamic/firebase_options.dart';

import 'core/di/service_locator.dart';
import 'core/env/app_env.dart';
import 'core/router/app_router.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/notification_message_handler.dart';
import 'core/services/push_token_service.dart';
import 'core/services/remote_notification_store_service.dart';
import 'features/auth/data/service/local_storage.dart';

Future<void> _handleRemoteMessageNavigation(RemoteMessage message) async {
  await NotificationMessageHandler.navigateFromMessage(
    message,
    navigateToRoom: LocalNotificationService.navigateToRoom,
  );
}

Future<void> _configureFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final canUsePush =
      settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;

  if (canUsePush) {
    await PushTokenService.syncCurrentUserToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      PushTokenService.syncCurrentUserToken(token: token);
    });
  }

  FirebaseMessaging.onMessage.listen((message) async {
    await RemoteNotificationStoreService.storeIncomingMessageForCurrentUser(
      message,
    );
    await NotificationMessageHandler.handleForegroundMessage(
      message,
      showNotification: LocalNotificationService.showHeadsUpNotification,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageNavigation);
}

Future<void> _handleInitialNotificationRoutes() async {
  final launchedFromLocalNotification =
      await LocalNotificationService.handleLaunchDetails();

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (!launchedFromLocalNotification && initialMessage != null) {
    await _handleRemoteMessageNavigation(initialMessage);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalStorageService.init();
  await LocalNotificationService.initialize();
  await RemoteNotificationStoreService.storeIncomingMessageForCurrentUser(
    message,
  );

  await LocalNotificationService.showHeadsUpNotification(
    id: NotificationMessageHandler.resolveNotificationId(message),
    title: NotificationMessageHandler.resolveTitle(message),
    body: NotificationMessageHandler.resolveBody(message),
    payload: NotificationMessageHandler.buildPayload(message),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  await dotenv.load(fileName: '.env');

  // 2. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    log('Firebase initialization failed: $e');
  }

  // 3. Initialize Local Storage & Stripe
  await LocalStorageService.init();
  await LocalNotificationService.initialize();
  await _configureFirebaseMessaging();

  try {
    Stripe.publishableKey = AppEnv.stripePublishableKey;
    await Stripe.instance.applySettings();
  } catch (e) {
    log('Stripe initialization failed: $e');
  }

  // 4. Setup Dependency Injection
  setupServiceLocator();

  runApp(DevicePreview(enabled: false, builder: (context) => const NoorApp()));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _handleInitialNotificationRoutes();
  });
}

class NoorApp extends StatelessWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Noor Islamic',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}
