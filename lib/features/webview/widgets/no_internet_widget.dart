import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_theme.dart';

/// Branded offline screen shown when there is no internet connection.
/// Includes retry button with haptic feedback and auto-retry capability.
class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlack,
      width: double.infinity,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Brand logo
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 90,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Icon(
                  Icons.local_fire_department,
                  color: AppTheme.accentRed,
                  size: 64,
                );
              },
            ),
            const SizedBox(height: 48),
            // Offline icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppTheme.accentGold,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin conexion a internet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Verifica tu conexion Wi-Fi o datos moviles e intenta nuevamente.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textWhite.withValues(alpha: 0.7),
                    ),
              ),
            ),
            const SizedBox(height: 40),
            // Retry button with haptic feedback
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onRetry();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
