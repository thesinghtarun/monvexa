import 'package:get/get.dart';
import 'package:monvexa/controller/screens/home_screen_controller.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/controller/tabs/settings_tab_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeTabController>(() => HomeTabController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
