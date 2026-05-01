import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/app.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/notifications/firebase_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait (matches website design)
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize services
  try {
    await FirebaseService.instance.initialize();
  } catch (e) {
    // Firebase may not be configured yet (first build without google-services)
    debugPrint('Firebase initialization skipped: $e');
  }
  try {
    ConnectivityService.instance.initialize();
  } catch (e) {
    debugPrint('ConnectivityService initialization skipped: $e');
  }

  runApp(const DrParrillaApp());
}
