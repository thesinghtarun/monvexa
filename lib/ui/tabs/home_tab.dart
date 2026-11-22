import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/image_const.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/models/transaction_model.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/services/ad_service.dart';
import 'package:monvexa/widgets/home_tab/account_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeTabController.to;

    return SafeArea(
      top: false,
      child: Obx(() {
        final state = controller.uiState.value;

        if (state == 'loading') {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state == 'noAccount') {
          return const _NoAccountView();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AccountCard(),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    StringConst.recentTransactions,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Obx(() {
                    final count = controller.recentFiveTransactions.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Last $count',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: Obx(() {
                final list = controller.recentFiveTransactions;

                if (list.isEmpty) {
                  return const _EmptyTransactionsView();
                }

                final hasBanner = Get.isRegistered<AdService>() &&
                    AdService.to.isBannerShowing.value;
                final bottomClearance = hasBanner ? 175.0 : 120.0;

                return ListView.separated(
                  itemCount: list.length,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomClearance),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final txn = list[index];
                    return _TransactionCard(transaction: txn);
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txnDate = DateTime(dt.year, dt.month, dt.day);

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    if (txnDate == today) {
      return 'Today, $timeStr';
    } else if (txnDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $timeStr';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final accentColor = isCredit ? const Color(0xFF059669) : const Color(0xFF1F2937);
    final badgeBg = isCredit ? const Color(0xFFE6F4EA) : const Color(0xFFF3F4F6);
    final badgeIcon = isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final iconColor = isCredit ? const Color(0xFF059669) : const Color(0xFF4B5563);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            // Glossy glass gradient matching Monvexa theme
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.80),
                AppColors.surface.withValues(alpha: 0.60),
                const Color(0xFFE6F5F0).withValues(alpha: 0.72),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            // High-sheen glass outline
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.90),
              width: 1.2,
            ),
            // Ambient soft drop shadow
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.7),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category / type badge with frosted pill container
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: badgeBg.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  badgeIcon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Merchant & formatted info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (transaction.description.isNotEmpty) ...[
                          Text(
                            transaction.description,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                        Text(
                          _formatDate(transaction.date),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Clean, high-contrast amount
              Text(
                '${isCredit ? "+" : "-"} ₹${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactionsView extends StatelessWidget {
  const _EmptyTransactionsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              StringConst.noTransactionsFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              StringConst.readingAccount,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoAccountView extends StatelessWidget {
  const _NoAccountView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ImageConst.noAccountFound, width: 400, height: 400),
          const SizedBox(height: 16),
          const Text(
            StringConst.noAccountFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            StringConst.tapBelowToAddAccount,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 26),

          // Scan & Detect Accounts Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(AppRoutes.accountDetection)?.then((_) {
                    HomeTabController.to.loadAccountsFromDb();
                  });
                },
                icon: const Icon(Icons.document_scanner_rounded, size: 20),
                label: const Text(
                  StringConst.scanAndDetectAccounts,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
