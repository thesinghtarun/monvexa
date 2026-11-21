import 'package:get/get.dart';
import 'package:monvexa/controller/screens/account_detection_controller.dart';

class AccountDetectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountDetectionController>(
      () => AccountDetectionController(),
    );
  }
}
