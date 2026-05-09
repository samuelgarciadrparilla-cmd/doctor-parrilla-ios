import 'package:flutter/material.dart';
import '../shared/theme/app_theme.dart';
import '../features/webview/webview_screen.dart';
import 'constants.dart';

class DrParrillaApp extends StatelessWidget {
  const DrParrillaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WebViewScreen(),
    );
  }
}
