
import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/icon_const.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/widgets/common/glass_container.dart';
import 'package:monvexa/widgets/home_tab/account_switcher_bottom_sheet.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeTabController.to;

    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(38),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background glass effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 12,
                20,
                14,
              ),
              child: Column(
                children: [
                  // --------------------------------
                  // HEADER
                  // --------------------------------

                  Row(
                    children: [
                      const Text(
                        StringConst.hello,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Account selector
                      Expanded(
                        child: Obx(
                          () => GestureDetector(
                            onTap: showAccountSwitcherBottomSheet,
                            child: GlassContainer(
                              blur: 10,
                              opacity: 0.22,
                              radius: 30,
                              tint: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller.activeAccountName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Add account
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.accountDetection,
                          )?.then((_) {
                            controller.loadAccountsFromDb();
                          });
                        },
                        child: GlassContainer(
                          blur: 10,
                          opacity: 0.22,
                          radius: 50,
                          tint: Colors.white,
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // --------------------------------
                  // TOTAL BALANCE TITLE
                  // --------------------------------

                 Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          StringConst.totalBal,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                 

                  const SizedBox(height: 8),

                  // --------------------------------
                  // BALANCE AMOUNT
                  // --------------------------------

                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              controller.showBal.value
                                  ? '₹ ${controller.active.value?.balance ?? 0}'
                                  : StringConst.encryptedBal,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: controller.toggleShowBal,
                          child: Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.17,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Icon(
                              controller.showBal.value
                                  ? IconConst.showBal
                                  : IconConst.hideBal,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 7),

                
                  // --------------------------------
                  // FL CHART
                  // --------------------------------

                  const SizedBox(height: 8),

                  const Expanded(
                    child: BalanceLineChart(),
                  ),

                  // --------------------------------
                  // INCOME & EXPENSE
                  // --------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: CreditDebitBal(
                          balance: '₹ 1,000',
                          icon: IconConst.creditBal,
                          isCredit: true,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: CreditDebitBal(
                          balance: '₹ 1,000',
                          icon: IconConst.debitedBal,
                          isCredit: false,
                        ),
                      ),
                    ],
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

// ==================================================
// BALANCE LINE CHART
// ==================================================

class BalanceLineChart extends StatelessWidget {
  const BalanceLineChart({super.key});

  static const List<FlSpot> dummyPoints = [
    FlSpot(0, 3),
    FlSpot(1, 6),
    FlSpot(2, 4),
    FlSpot(3, 8),
    FlSpot(4, 7),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 4,
          minY: 0,
          maxY: 10,

          // Remove axes and grid
          gridData: const FlGridData(
            show: false,
          ),

          titlesData: const FlTitlesData(
            show: false,
          ),

          borderData: FlBorderData(
            show: false,
          ),

          // Disable touch indicators for clean UI
          lineTouchData: const LineTouchData(
            enabled: false,
          ),

          // Dotted vertical guide lines
          extraLinesData: ExtraLinesData(
            verticalLines: dummyPoints.map((spot) {
              return VerticalLine(
                x: spot.x,
                color: Colors.white.withValues(alpha: 0.18),
                strokeWidth: 1,
                dashArray: [3, 4],
              );
            }).toList(),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: dummyPoints,

              // Smooth curve
              isCurved: true,
              curveSmoothness: 0.35,

              barWidth: 3,
              isStrokeCapRound: true,
              isStrokeJoinRound: true,

              // Gradient line
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFBFFFF3),
                  Color(0xFF00FFD0),
                ],
              ),

              // Neon glow
              shadow: const Shadow(
                color: Color(0x8800FFD0),
                blurRadius: 12,
              ),

              // Gradient below the curve
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00FFD0).withValues(
                      alpha: 0.22,
                    ),
                    const Color(0xFF00FFD0).withValues(
                      alpha: 0.0,
                    ),
                  ],
                ),
              ),

              // Circular points
              dotData: FlDotData(
                show: true,
                getDotPainter: (
                  spot,
                  percent,
                  barData,
                  index,
                ) {
                  final isLast = index == dummyPoints.length - 1;

                  return FlDotCirclePainter(
                    radius: isLast ? 7 : 4.5,
                    color: isLast
                        ? Colors.white
                        : const Color(0xFF00EFC0),
                    strokeWidth: isLast ? 3 : 1.5,
                    strokeColor: isLast
                        ? const Color(0xFF00EFC0)
                        : Colors.white,
                  );
                },
              ),
            ),
          ],
        ),

        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ),
    );
  }
}

// ==================================================
// INCOME / EXPENSE GLASS CARD
// ==================================================

class CreditDebitBal extends StatelessWidget {
  const CreditDebitBal({
    super.key,
    required this.balance,
    required this.icon,
    this.isCredit = true,
  });

  final String balance;
  final IconData icon;
  final bool isCredit;

  @override
  Widget build(BuildContext context) {
    final accentColor = isCredit
        ? Colors.green
        : const Color(0xFFFF525D);

    final iconColor = isCredit
        ? const Color(0xFF008F70)
        : Colors.red;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          height: 102,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.10),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular icon
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.22),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.18),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 27,
                  color: iconColor,
                ),
              ),

              const SizedBox(width: 9),

              // Vertical divider
              Container(
                height: 68,
                width: 1,
                color: Colors.white.withValues(alpha: 0.45),
              ),

              const SizedBox(width: 9),

              // Details
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCredit ? 'Income' : 'Expense',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        balance,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      isCredit ? 'Money Received' : 'Money Spent',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
