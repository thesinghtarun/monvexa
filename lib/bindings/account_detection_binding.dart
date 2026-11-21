import 'package:get/get.dart';
import 'package:monvexa/controller/accounts/account_detection_controller.dart';

class AccountDetectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountDetectionController>(
      () => AccountDetectionController(),
    );
  }
}
