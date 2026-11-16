import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxMap<String, bool> settings = <String, bool>{
    'notifications': true,
    'darkMode': false,
    'biometric': false,
  }.obs;

  void updateSetting(String key, bool value) {
    settings[key] = value;
  }
}