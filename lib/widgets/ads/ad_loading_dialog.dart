import 'package:flutter/material.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/widgets/common/glass_container.dart';

class AdLoadingDialog extends StatelessWidget {
  const AdLoadingDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const PopScope(
        canPop: false,
        child: AdLoadingDialog(),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        blur: 16,
        opacity: 0.22,
        radius: 20,
        tint: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading Ad...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                decoration: TextDecoration.none,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
