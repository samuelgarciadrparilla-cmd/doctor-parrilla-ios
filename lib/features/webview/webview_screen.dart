import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../app/constants.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../core/notifications/firebase_service.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/loading_widget.dart';
import 'widgets/no_internet_widget.dart';
import 'widgets/error_widget.dart';

/// Possible states of the WebView screen.
enum WebViewState { loading, loaded, noInternet, error }

/// Main WebView screen that wraps the Doctor Parrilla website.
/// Handles all states: loading, loaded, no internet, error, back navigation.
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  WebViewState _state = WebViewState.loading;
  double _loadingProgress = 0;
  bool _canGoBack = false;

  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<String>? _notificationUrlSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWebView();
    _setupConnectivityListener();
    try {
      _setupNotificationListeners();
    } catch (_) {}
    _checkNotificationPermission().catchError((_) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _notificationUrlSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF080808))
      ..setUserAgent(AppConstants.userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _state = WebViewState.loading;
                _loadingProgress = 0;
              });
            }
          },
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100.0;
              });
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              setState(() {
                _state = WebViewState.loaded;
              });
              _canGoBack = await _controller.canGoBack();

              // Inject FCM token into WebView via JavaScript bridge
              _injectFcmToken();
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only handle main frame errors
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _state = WebViewState.error;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Open external links in system browser
            final Uri uri = Uri.parse(request.url);
            if (!request.url.startsWith(AppConstants.baseUrl) &&
                !request.url.startsWith('about:')) {
              _openExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..enableZoom(false);

    _loadPage();
  }

  Future<void> _loadPage() async {
    final bool isConnected =
        await ConnectivityService.instance.checkConnectivity();
    if (!isConnected) {
      if (mounted) {
        setState(() {
          _state = WebViewState.noInternet;
        });
      }
      return;
    }

    _controller.loadRequest(Uri.parse(AppConstants.baseUrl));
  }

  void _setupConnectivityListener() {
    _connectivitySubscription =
        ConnectivityService.instance.onConnectionChanged.listen(
      (bool isConnected) {
        if (isConnected && _state == WebViewState.noInternet) {
          _loadPage();
        }
      },
    );
  }

  void _setupNotificationListeners() {
    // Navigate WebView when notification URL is received
    _notificationUrlSubscription =
        FirebaseService.instance.onNotificationUrl.listen(
      (String url) {
        if (url.startsWith(AppConstants.baseUrl)) {
          _controller.loadRequest(Uri.parse(url));
        }
      },
    );

    // Show in-app banner for foreground notifications
    _foregroundMessageSubscription =
        FirebaseService.instance.onForegroundMessage.listen(
      _showInAppNotification,
    );
  }

  Future<void> _checkNotificationPermission() async {
    final FirebaseService firebase = FirebaseService.instance;
    await firebase.incrementAppOpenCount();

    if (await firebase.shouldRequestPermission()) {
      // Small delay to let the app settle before showing permission dialog
      await Future<void>.delayed(const Duration(seconds: 3));
      await firebase.requestPermission();
      await firebase.markPermissionAsked();
    }
  }

  Future<void> _injectFcmToken() async {
    final String? token = await FirebaseService.instance.getToken();
    if (token != null) {
      await _controller.runJavaScript(
        'window.postMessage({"type": "fcm_token", "token": "$token"}, "*");',
      );
    }
  }

  void _showInAppNotification(RemoteMessage message) {
    if (!mounted) return;
    final String title = message.notification?.title ?? '';
    final String body = message.notification?.body ?? '';
    if (title.isEmpty && body.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (body.isNotEmpty) Text(body),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver',
          textColor: AppTheme.accentGold,
          onPressed: () {
            final String? url = message.data['url'] as String?;
            if (url != null && url.startsWith(AppConstants.baseUrl)) {
              _controller.loadRequest(Uri.parse(url));
            }
          },
        ),
      ),
    );
  }

  Future<void> _openExternalUrl(String url) async {
    // Use platform channel to open in system browser
    // This ensures external links don't stay inside the WebView
    try {
      await _controller.runJavaScript(
        'window.open("$url", "_system");',
      );
    } catch (_) {
      // Fallback: do nothing, link was already prevented
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await _controller.reload();
  }

  Future<bool> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false; // Don't close app
    }
    return true; // Allow app to close
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool shouldPop = await _handleBackNavigation();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryBlack,
        body: SafeArea(
          top: false,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case WebViewState.noInternet:
        return NoInternetWidget(onRetry: _loadPage);
      case WebViewState.error:
        return WebViewErrorWidget(onRetry: _loadPage);
      case WebViewState.loading:
      case WebViewState.loaded:
        return Stack(
          children: <Widget>[
            WebViewWidget(
              controller: _controller,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                ),
                Factory<HorizontalDragGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer(),
                ),
                Factory<TapGestureRecognizer>(
                  () => TapGestureRecognizer(),
                ),
              },
            ),
            if (_state == WebViewState.loading)
              AnimatedOpacity(
                opacity: _state == WebViewState.loading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: LoadingWidget(progress: _loadingProgress),
              ),
          ],
        );
    }
  }
}
