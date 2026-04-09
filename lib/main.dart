import 'dart:developer';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tally_islamic/firebase_options.dart';

import 'core/di/service_locator.dart';
import 'core/env/app_env.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/service/local_storage.dart';

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

  try {
    Stripe.publishableKey = AppEnv.stripePublishableKey;
    await Stripe.instance.applySettings();
  } catch (e) {
    log('Stripe initialization failed: $e');
  }

  // 4. Setup Dependency Injection
  setupServiceLocator();

  runApp(
    DevicePreview(
      enabled: false, 
      builder: (context) => const TallyApp(),
    ),
  );
}

class TallyApp extends StatelessWidget {
  const TallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tally Islamic',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}

//dahym2028@gmail.com


// test123@gmail.com 
