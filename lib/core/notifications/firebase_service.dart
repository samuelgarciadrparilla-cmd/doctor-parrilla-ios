import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants.dart';
import '../../firebase_options.dart';

/// Handles all Firebase Cloud Messaging operations.
/// Requests permission contextually (not on first launch).
/// Manages FCM token lifecycle and notification handling.
class FirebaseService {
  FirebaseService._internal();
  static final FirebaseService instance = FirebaseService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundMessageController.stream;

  final StreamController<String> _notificationUrlController =
      StreamController<String>.broadcast();

  Stream<String> get onNotificationUrl => _notificationUrlController.stream;

  /// Initialize Firebase and set up message handlers.
  Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _foregroundMessageController.add(message);
      _handleNotificationData(message);
    });

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationData(message);
    });

    // Handle terminated state message taps
    final RemoteMessage? initialMessage =
        await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationData(initialMessage);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((String token) {
      _saveToken(token);
    });
  }

  /// Request notification permission contextually.
  /// Call this after the user's second app open or first order.
  Future<bool> requestPermission() async {
    try {
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final bool granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (granted) {
        await _getAndSaveToken();
      }

      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Check if it's appropriate to request notification permission.
  /// Returns true on the second app open (contextual, not first launch).
  Future<bool> shouldRequestPermission() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool alreadyAsked =
        prefs.getBool(AppConstants.keyNotificationPermissionAsked) ?? false;

    if (alreadyAsked) return false;

    final int openCount = prefs.getInt(AppConstants.keyAppOpenCount) ?? 0;
    return openCount >= 2;
  }

  /// Increment app open count for contextual permission request.
  Future<void> incrementAppOpenCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int count = prefs.getInt(AppConstants.keyAppOpenCount) ?? 0;
    await prefs.setInt(AppConstants.keyAppOpenCount, count + 1);
  }

  /// Mark that notification permission has been asked.
  Future<void> markPermissionAsked() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotificationPermissionAsked, true);
  }

  /// Get the current FCM token.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _getAndSaveToken() async {
    final String? token = await getToken();
    if (token != null) {
      await _saveToken(token);
    }
  }

  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyFcmToken, token);
  }

  void _handleNotificationData(RemoteMessage message) {
    final String? url = message.data['url'] as String?;
    if (url != null && url.isNotEmpty) {
      _notificationUrlController.add(url);
    }
  }

  /// Dispose of resources.
  void dispose() {
    _foregroundMessageController.close();
    _notificationUrlController.close();
  }
}

/// Top-level background message handler (required by Firebase).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
