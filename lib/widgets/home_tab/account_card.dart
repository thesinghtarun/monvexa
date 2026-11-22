import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';
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
      height: 400,
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
            // Positioned.fill(
            //   child: BackdropFilter(
            //     filter: ImageFilter.blur(
            //       sigmaX: 10,
            //       sigmaY: 10,
            //     ),
            //     child: Container(
            //       color: Colors.black.withValues(alpha: 0.04),
            //     ),
            //   ),
            // ),

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
                                   Icon(
                                    IconConst.dropDown,
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

                  const SizedBox(height: 20),

                  // --------------------------------
                  // TOTAL BALANCE TITLE
                  // --------------------------------
                 
                     
                      Text(
                        StringConst.totalBal,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
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
                                  ? '₹ ${controller.active.value?.balance.toStringAsFixed(2) ?? '0.00'}'
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

                  const SizedBox(height: 15),

                  // --------------------------------
                  // INCOME & EXPENSE (TODAY)
                  // --------------------------------
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: CreditDebitBal(
                            title: StringConst.todaysIncome,
                            balance: '₹ ${controller.todayCreditAmount.value.toStringAsFixed(0)}',
                            icon: IconConst.creditBal,
                            isCredit: true,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: CreditDebitBal(
                            title: StringConst.todaysExpense,
                            balance: '₹ ${controller.todayDebitAmount.value.toStringAsFixed(0)}',
                            icon: IconConst.debitedBal,
                            isCredit: false,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --------------------------------
                  // FL CHART (TODAY TREND)
                  // --------------------------------
                  const SizedBox(height: 8),

                  const Expanded(
                    child: BalanceLineChart(),
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

  @override
  Widget build(BuildContext context) {
    final controller = HomeTabController.to;

    return Obx(() {
      final spots = controller.todayChartSpots;

      if (spots.length < 2) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  StringConst.noActivityToday,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      if (minY == maxY) {
        minY = minY > 0 ? minY * 0.9 : -10;
        maxY = maxY > 0 ? maxY * 1.1 : 10;
      } else {
        // Add a comfortable 8% margin above and below so the curve never clips at the edges
        final padding = (maxY - minY) * 0.12;
        minY = (minY - padding).clamp(0.0, double.infinity);
        maxY += padding;
      }

      return SizedBox(
        width: double.infinity,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (spots.length - 1).toDouble(),
            minY: minY,
            maxY: maxY,

            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: const LineTouchData(enabled: false),

            extraLinesData: ExtraLinesData(
              verticalLines: spots.map((spot) {
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
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                barWidth: 3,
                isStrokeCapRound: true,
                isStrokeJoinRound: true,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFBFFFF3),
                    Color(0xFF00FFD0),
                  ],
                ),
                shadow: const Shadow(
                  color: Color(0x8800FFD0),
                  blurRadius: 12,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF00FFD0).withValues(alpha: 0.22),
                      const Color(0xFF00FFD0).withValues(alpha: 0.0),
                    ],
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final isLast = index == spots.length - 1;
                    return FlDotCirclePainter(
                      radius: isLast ? 6 : 4,
                      color: isLast ? Colors.white : const Color(0xFF00EFC0),
                      strokeWidth: isLast ? 2.5 : 1.2,
                      strokeColor: isLast ? const Color(0xFF00EFC0) : Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        ),
      );
    });
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
    this.title = 'Income',
    this.isCredit = true,
  });

  final String title;
  final String balance;
  final IconData icon;
  final bool isCredit;

  @override
  Widget build(BuildContext context) {
    final accentColor = isCredit
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);

    final iconColor = isCredit
        ? const Color(0xFF008F70)
        : const Color(0xFFDC2626);

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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                          fontSize: 20,
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
