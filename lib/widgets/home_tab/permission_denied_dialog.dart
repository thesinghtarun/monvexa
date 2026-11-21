import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/widgets/common/glass_container.dart';

/// Factory so HomeTabController can reference this widget without
/// a circular import — controller imports factory, not the full widget file.
class PermissionDeniedDialogFactory {
  static Widget build() => const PermissionDeniedDialog();
}

class PermissionDeniedDialog extends StatelessWidget {
  const PermissionDeniedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeTabController.to;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: GlassContainer(
        blur: 18,
        opacity: 0.18,
        radius: 24,
        tint: Colors.white,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              StringConst.smsPermissionRequired,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),

            // Body
            const Text(
              StringConst.smsPermissionDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Buttons row
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.onPermissionDialogCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      StringConst.cancelButton,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Open Settings
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.onPermissionDialogOpenSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      StringConst.openSettingsButton,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
