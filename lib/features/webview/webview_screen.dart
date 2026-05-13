import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../app/constants.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../core/notifications/firebase_service.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/loading_widget.dart';
import 'widgets/no_internet_widget.dart';
import 'widgets/error_widget.dart';

enum WebViewState { loading, loaded, noInternet, error }

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
  DateTime? _backgroundedAt;

  static const Duration _refreshThreshold = Duration(minutes: 10);
  static const Duration _syncInterval = Duration(seconds: 60);

  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<String>? _notificationUrlSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  Timer? _syncTimer;

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
    _startSyncTimer();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _notificationUrlSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    super.dispose();
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      if (_state == WebViewState.loaded) {
        _controller.runJavaScript(
          'try{window.postMessage(JSON.stringify({"type":"sync_now"}),"*");}catch(e){}',
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _backgroundedAt != null) {
      final Duration elapsed = DateTime.now().difference(_backgroundedAt!);
      _backgroundedAt = null;

      if (elapsed >= _refreshThreshold) {
        _loadPage();
      } else {
        _controller.runJavaScript(
          'try{window.postMessage(JSON.stringify({"type":"sync_now"}),"*");}catch(e){}',
        );
      }
    }
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
              _injectFcmToken();
              _injectExternalLinkHandler();
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _state = WebViewState.error;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final String url = request.url;
            final bool isPdf = url.toLowerCase().contains('.pdf');

            // Allow Firebase internal URLs (Auth, Database, Storage, etc.)
            final bool isFirebaseInternal = url.contains('firebaseapp.com') ||
                url.contains('firebaseio.com') ||
                url.contains('firebasestorage.googleapis.com') ||
                url.contains('googleapis.com') ||
                url.contains('gstatic.com') ||
                url.contains('accounts.google.com');

            // If it's a Firebase internal URL, NEVER open externally - just allow or block silently
            if (isFirebaseInternal) {
              // Block long-polling URLs from navigating (they should be XHR, not navigation)
              if (url.contains('.lp?') || url.contains('/.lp')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            }

            final bool isExternal = !url.startsWith(AppConstants.baseUrl) &&
                !url.startsWith('about:');

            if (isPdf || isExternal) {
              _openExternalUrl(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'DrParrillaApp',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final Map<String, dynamic> data = json.decode(message.message);
            if (data['type'] == 'external_url' && data['url'] != null) {
              _openExternalUrl(data['url'] as String);
            }
          } catch (_) {}
        },
      );

    _loadPage();
  }

  Future<void> _loadPage() async {
    final bool isConnected =
        await ConnectivityService.instance.checkConnectivity();
    if (!isConnected) {
      if (mounted) setState(() => _state = WebViewState.noInternet);
      return;
    }

    // Primary: use compile-time SCREENSHOT_URL (for Codemagic screenshots)
    const String screenshotUrl = String.fromEnvironment('SCREENSHOT_URL', defaultValue: '');
    final String targetUrl = screenshotUrl.isNotEmpty ? screenshotUrl : AppConstants.baseUrl;

    _controller.loadRequest(Uri.parse(targetUrl));
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
    _notificationUrlSubscription =
        FirebaseService.instance.onNotificationUrl.listen(
      (String url) {
        if (url.startsWith(AppConstants.baseUrl)) {
          _controller.loadRequest(Uri.parse(url));
        }
      },
    );

    _foregroundMessageSubscription =
        FirebaseService.instance.onForegroundMessage.listen(
      _showInAppNotification,
    );
  }

  Future<void> _checkNotificationPermission() async {
    // Skip notification permission in screenshot mode
    const String screenshotUrl = String.fromEnvironment('SCREENSHOT_URL', defaultValue: '');
    if (screenshotUrl.isNotEmpty) {
      return;
    }

    final FirebaseService firebase = FirebaseService.instance;
    await firebase.incrementAppOpenCount();

    if (await firebase.shouldRequestPermission()) {
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

  Future<void> _injectExternalLinkHandler() async {
    const String baseUrl = AppConstants.baseUrl;
    await _controller.runJavaScript('''
      (function() {
        if (window._drParrillaLinksInjected) return;
        window._drParrillaLinksInjected = true;

        // URLs that should NOT be intercepted (Firebase internal URLs)
        const isInternalUrl = (url) => {
          if (!url) return true;
          if (url.startsWith('$baseUrl')) return true;
          if (url.startsWith('/') || url.startsWith('#')) return true;
          if (url.includes('firebaseapp.com')) return true;
          if (url.includes('firebaseio.com')) return true;
          if (url.includes('firebasestorage.googleapis.com')) return true;
          if (url.includes('googleapis.com')) return true;
          if (url.includes('gstatic.com')) return true;
          if (url.includes('accounts.google.com')) return true;
          return false;
        };

        // Intercept window.open()
        const originalOpen = window.open;
        window.open = function(url, target, features) {
          if (url && !isInternalUrl(url)) {
            if (window.DrParrillaApp) {
              window.DrParrillaApp.postMessage(JSON.stringify({type:'external_url', url:url}));
            }
            return null;
          }
          return originalOpen.call(window, url, target, features);
        };

        // Intercept target="_blank" links
        document.addEventListener('click', function(e) {
          const link = e.target.closest('a[target="_blank"]');
          if (link && link.href && !isInternalUrl(link.href)) {
            e.preventDefault();
            e.stopPropagation();
            if (window.DrParrillaApp) {
              window.DrParrillaApp.postMessage(JSON.stringify({type:'external_url', url:link.href}));
            }
          }
        }, true);

        console.log('[DrParrilla] External link handler injected');
      })();
    ''');
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (body.isNotEmpty) Text(body),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<bool> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
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
            ColoredBox(
              color: Colors.black,
              child: WebViewWidget(
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
