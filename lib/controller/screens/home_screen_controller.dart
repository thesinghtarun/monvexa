import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/ui/tabs/home_tab.dart';
import 'package:monvexa/ui/tabs/scan_tab.dart';
import 'package:monvexa/ui/tabs/settings_tab.dart';
import 'package:monvexa/ui/tabs/wallet_tab.dart';

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<Widget> tabs = const [
    HomeTab(),
    ScanTab(),
    WalletTab(),
    SettingsTab(),
  ];

  void changeTabIndex(int index) {
    selectedIndex.value = index;

    // Whenever user switches back to HomeTab (index 0), check permission
    if (index == 0) {
      if (Get.isRegistered<HomeTabController>()) {
        HomeTabController.to.checkPermissionAndPrompt();
      }
    }
  }
}
