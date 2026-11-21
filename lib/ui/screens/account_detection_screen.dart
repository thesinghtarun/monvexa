import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/accounts/account_detection_controller.dart';
import 'package:monvexa/widgets/common/glass_container.dart';

class AccountDetectionScreen extends GetView<AccountDetectionController> {
  const AccountDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryDark),
          onPressed: controller.skipToHome,
        ),
        actions: [
          TextButton(
            onPressed: controller.skipToHome,
            child: const Text(
              StringConst.closeButton,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.stage.value) {
            case ScanStage.inProgress:
              return _buildProgressView(context);
            case ScanStage.found:
              return _buildFoundAccountsView(context);
            case ScanStage.notFound:
              return _buildNotFoundView(context);
          }
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. STEP-BY-STEP PROGRESS VIEW
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProgressView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            StringConst.settingUpAccounts,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            StringConst.readingAccount,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),

          GlassContainer(
            blur: 12,
            opacity: 0.35,
            radius: 20,
            tint: Colors.white,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: List.generate(controller.progressSteps.length, (index) {
                final isDone = controller.stepCompleted[index];
                final isActive = controller.activeStepIndex.value == index;
                final isPending = index > controller.activeStepIndex.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.primary
                              : (isActive
                                  ? AppColors.primary.withOpacity(0.15)
                                  : Colors.grey.shade200),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                              : (isActive
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.grey.shade400,
                                    )),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          controller.progressSteps[index],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isActive || isDone ? FontWeight.w600 : FontWeight.w400,
                            color: isPending
                                ? Colors.grey.shade400
                                : (isDone ? AppColors.primaryDark : AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const Spacer(),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  StringConst.onDevicePrivacy,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. FOUND ACCOUNTS VIEW
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFoundAccountsView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            StringConst.newAccountsFound,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            StringConst.newAccountsDiscovered(controller.detectedAccounts.length),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: controller.detectedAccounts.length,
              itemBuilder: (context, index) {
                final item = controller.detectedAccounts[index];

                return GestureDetector(
                  onTap: () => controller.toggleSelection(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item.isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: item.isSelected ? AppColors.primary : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Checkbox
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.isSelected ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: item.isSelected ? AppColors.primary : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: item.isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.bankName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '..${item.accountNumber}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.balance > 0
                                    ? 'Balance: ₹ ${item.balance.toStringAsFixed(2)} • ${item.messageCount} alerts'
                                    : '${item.sender} • ${item.messageCount} alerts',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: controller.detectedAccounts.any((a) => a.isSelected)
                  ? controller.confirmAndContinue
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                StringConst.confirmAndSaveAccounts,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. NOT FOUND / NO NEW ACCOUNTS VIEW
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNotFoundView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            StringConst.noNewAccountsFound,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            StringConst.noNewAccountsDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),

          // Retry Scan Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: controller.retryScan,
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
              label: const Text(
                StringConst.retryScan,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Continue to Home Tab
          TextButton(
            onPressed: controller.skipToHome,
            child: const Text(
              StringConst.backToHomeTab,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
