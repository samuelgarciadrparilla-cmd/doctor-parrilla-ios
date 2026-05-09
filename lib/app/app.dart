import 'package:flutter/material.dart';
import '../shared/theme/app_theme.dart';
import '../features/auth/auth_service.dart';
import '../features/auth/login_screen.dart';
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
      home: FutureBuilder<String?>(
        future: AuthService.instance.getSavedPhone(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: SizedBox.shrink(),
            );
          }
          if (snapshot.data != null) {
            return const WebViewScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
