import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/icon_const.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/widgets/common/glass_container.dart';
import 'package:monvexa/widgets/home_tab/account_switcher_bottom_sheet.dart';
import 'package:monvexa/widgets/home_tab/add_account_bottom_sheet.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeTabController.to;

    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.surface],
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
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  StringConst.hello,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // ── Account Selector (Glass Effect + Functional) ──
                Obx(
                  () => GestureDetector(
                    onTap: showAccountSwitcherBottomSheet,
                    child: GlassContainer(
                      blur: 10,
                      opacity: 0.22,
                      radius: 30,
                      tint: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.activeAccountName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Add Another Account (Glass Effect + Functional) ──
                GestureDetector(
                  onTap: showAddAccountBottomSheet,
                  child: GlassContainer(
                    blur: 10,
                    opacity: 0.22,
                    radius: 50,
                    tint: Colors.white,
                    padding: const EdgeInsets.all(7),
                    child: Icon(IconConst.add, size: 24.0, color: Colors.white),
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
