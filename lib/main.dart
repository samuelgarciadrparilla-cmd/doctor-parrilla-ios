import 'dart:ui' show PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/app.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/notifications/firebase_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any unhandled Flutter or async errors — log instead of crash
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Unhandled error: $error');
    return true;
  };

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase core FIRST so FirebaseMessaging.instance is safe to call
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  try {
    await FirebaseService.instance.initialize();
  } catch (e) {
    debugPrint('Firebase service setup skipped: $e');
  }

  try {
    ConnectivityService.instance.initialize();
  } catch (e) {
    debugPrint('ConnectivityService initialization skipped: $e');
  }

  runApp(const DrParrillaApp());
}
