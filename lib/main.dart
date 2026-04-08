import 'dart:developer';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tally_islamic/firebase_options.dart';

import 'core/di/service_locator.dart';
import 'core/env/app_env.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    log('Firebase initialization failed: $e');
  }

  try {
    Stripe.publishableKey = AppEnv.stripePublishableKey;
    await Stripe.instance.applySettings();
  } catch (e) {
    log('Stripe initialization failed: $e');
  }

  setupServiceLocator();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const TallyApp(),
    ),
  );
}

class TallyApp extends StatelessWidget {
  const TallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tally',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}