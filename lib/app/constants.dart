/// All app-wide constants. No hardcoded values anywhere else.
class AppConstants {
  AppConstants._();

  // ─── URLs ───────────────────────────────────────────────
  static const String baseUrl = 'https://drparrillaparaguay.com';
  static const String privacyPolicyUrl = '$baseUrl/privacidad';
  static const String supportUrl = baseUrl;

  // ─── App Info ───────────────────────────────────────────
  static const String appName = 'Doctor Parrilla';
  static const String appVersion = '1.0.0';
  static const String bundleId = 'com.drparrilla.app';
  static const String userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';

  // ─── Brand Colors (hex) ─────────────────────────────────
  static const int primaryBlack = 0xFF000000;
  static const int accentGold = 0xFFD4AF37;
  static const int accentRed = 0xFFE85D2A;
  static const int textWhite = 0xFFFFFFFF;
  static const int surfaceDark = 0xFF1A1A1A;
  static const int errorRed = 0xFFCF6679;

  // ─── Timing ─────────────────────────────────────────────
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration retryDelay = Duration(seconds: 3);

  // ─── Notification Settings ──────────────────────────────
  static const String notificationChannelId = 'dr_parrilla_notifications';
  static const String notificationChannelName = 'Doctor Parrilla';
  static const String notificationChannelDesc =
      'Notificaciones de Doctor Parrilla Paraguay';

  // ─── SharedPreferences Keys ─────────────────────────────
  static const String keyAppOpenCount = 'app_open_count';
  static const String keyFcmToken = 'fcm_token';
  static const String keyNotificationPermissionAsked =
      'notification_permission_asked';
}
