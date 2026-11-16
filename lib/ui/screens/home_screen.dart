import 'package:flutter/cupertino.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/constants/icon_const.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/screens/home_screen_controller.dart';
import 'package:monvexa/widgets/home_screen/navigation_item.dart';
import 'package:monvexa/widgets/home_screen/liquiid_glass_nav_bar.dart';

// ─── Home Screen ─────────────────────────────────────────────────────────────

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  static const List<NavigationItem> navItems = [
    NavigationItem(
      icon: IconConst.homeUnFill,
      selectedIcon: IconConst.homeFill,
      label: StringConst.home,
    ),
    NavigationItem(
      icon: IconConst.scanUnFill,
      selectedIcon: IconConst.scanFill,
      label: StringConst.scan,
    ),
    NavigationItem(
      icon: IconConst.walletUnFill,
      selectedIcon: IconConst.walletFill,
      label: StringConst.wallet,
    ),
    NavigationItem(
      icon: IconConst.settingsUnFill,
      selectedIcon: IconConst.settingsFill,
      label: StringConst.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Current tab content
          Obx(() => controller.tabs[controller.selectedIndex.value]),

          // Floating glass bottom navigation
          Obx(
            () => Align(
              alignment: Alignment.bottomCenter,
              child: LiquidGlassNavBar(
                items: navItems,
                selectedIndex: controller.selectedIndex.value,
                onTap: controller.changeTabIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
