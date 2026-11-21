import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/models/account_model.dart';
import 'package:monvexa/widgets/home_tab/add_account_bottom_sheet.dart';

/// Call this to show the account switcher sheet
void showAccountSwitcherBottomSheet() {
  Get.bottomSheet(
    const _AccountSwitcherSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

class _AccountSwitcherSheet extends StatelessWidget {
  const _AccountSwitcherSheet();

  @override
  Widget build(BuildContext context) {
    final controller = HomeTabController.to;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'My Accounts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),

              Obx(() {
                final accounts = controller.accounts;
                final active = controller.active.value;

                if (accounts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No accounts added yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: accounts.map((account) {
                    final isActive = active?.id == account.id;
                    return _AccountTile(
                      account: account,
                      isActive: isActive,
                      onTap: () {
                        controller.setActive(account);
                        Get.back();
                      },
                    );
                  }).toList(),
                );
              }),

              const Divider(height: 24),

              // Add new account
              InkWell(
                onTap: () {
                  Get.back(); // close switcher
                  showAddAccountBottomSheet();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Add New Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.isActive,
    required this.onTap,
  });

  final AccountModel account;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive
                    ? Icons.check_rounded
                    : Icons.account_balance_wallet_rounded,
                color: isActive ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    account.bankName,
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
  }
}
