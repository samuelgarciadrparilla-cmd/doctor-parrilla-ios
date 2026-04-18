import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';

/// Loading widget that shows a progress bar and skeleton-like shimmer effect.
/// Mimics the website layout to avoid blank white screens.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlack,
      child: Column(
        children: <Widget>[
          // Progress bar at top (native feel)
          LinearProgressIndicator(
            value: progress > 0 ? progress : null,
            backgroundColor: AppTheme.surfaceDark,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
            minHeight: 3,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Brand logo placeholder
                  Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 90,
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Icon(
                        Icons.local_fire_department,
                        color: AppTheme.accentRed,
                        size: 64,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Skeleton shimmer blocks
                  _buildSkeletonBlock(width: 240, height: 16),
                  const SizedBox(height: 12),
                  _buildSkeletonBlock(width: 180, height: 16),
                  const SizedBox(height: 12),
                  _buildSkeletonBlock(width: 200, height: 16),
                  const SizedBox(height: 24),
                  _buildSkeletonBlock(width: 160, height: 44),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBlock({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
