import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monvexa/constants/app_colors.dart';

class FullscreenNativeTemplate extends StatelessWidget {
  final NativeAd nativeAd;
  final VoidCallback onDismiss;

  const FullscreenNativeTemplate({
    super.key,
    required this.nativeAd,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AdWidget(ad: nativeAd),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: onDismiss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
