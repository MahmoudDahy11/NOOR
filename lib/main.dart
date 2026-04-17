import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tally_islamic/firebase_options.dart';

import 'core/constants/app_keys.dart';
import 'core/di/service_locator.dart';
import 'core/env/app_env.dart';
import 'core/router/app_router.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/notification_message_handler.dart';
import 'features/auth/data/service/local_storage.dart';

Future<void> _handleRemoteMessageNavigation(RemoteMessage message) async {
  await NotificationMessageHandler.navigateFromMessage(
    message,
    navigateToRoom: LocalNotificationService.navigateToRoom,
  );
}

Future<void> _configureFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen(
    (message) => NotificationMessageHandler.handleForegroundMessage(
      message,
      showNotification: LocalNotificationService.showHeadsUpNotification,
    ),
  );

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

  final authUid = FirebaseAuth.instance.currentUser?.uid;
  final cachedUid = LocalStorageService.getUserId();
  final uid = authUid ?? cachedUid;

  if (uid != null && uid.isNotEmpty) {
    final notificationId =
        message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final data = Map<String, dynamic>.from(message.data);
    final roomId = NotificationMessageHandler.extractRoomId(message);

    await FirebaseFirestore.instance
        .collection(AppKeys.usersCollection)
        .doc(uid)
        .collection(AppKeys.notificationsCollection)
        .doc(notificationId)
        .set({
          AppKeys.notificationId: notificationId,
          AppKeys.notificationTitle:
              message.notification?.title ??
              data[AppKeys.notificationTitle] ??
              'Tally Islamic',
          AppKeys.notificationBody:
              message.notification?.body ??
              data[AppKeys.notificationBody] ??
              '',
          AppKeys.notificationType: data[AppKeys.notificationType] ?? 'system',
          AppKeys.notificationRoomId: roomId,
          AppKeys.notificationRoute: data[AppKeys.notificationRoute],
          AppKeys.notificationData: data,
          AppKeys.notificationIsRead: false,
          AppKeys.notificationSentAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

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
