import 'dart:async';

import 'package:get/get.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/models/account_model.dart';
import 'package:monvexa/services/sms_service.dart';
import 'package:monvexa/widgets/home_tab/add_account_bottom_sheet.dart';

enum ScanStage { inProgress, found, notFound }

class DetectedAccountItem {
  final String bankName;
  final String sender;
  final String accountNumber;
  final int messageCount;
  final String matchedBy;
  bool isSelected;

  DetectedAccountItem({
    required this.bankName,
    required this.sender,
    required this.accountNumber,
    required this.messageCount,
    required this.matchedBy,
    this.isSelected = true,
  });
}

class AccountDetectionController extends GetxController {
  final SmsService smsService = Get.find<SmsService>();

  // State management
  final Rx<ScanStage> stage = ScanStage.inProgress.obs;
  final RxInt activeStepIndex = 0.obs; // 0 to 4
  final RxList<bool> stepCompleted = <bool>[
    false,
    false,
    false,
    false,
    false,
  ].obs;

  final List<String> progressSteps = [
    StringConst.gettingStarted,
    StringConst.scanningInbox,
    StringConst.analyzingTransactions,
    StringConst.verifyingBank,
    StringConst.finalizingAccounts,
  ];

  final RxList<DetectedAccountItem> detectedAccounts =
      <DetectedAccountItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    startScanningProcess();
  }

  Future<void> startScanningProcess() async {
    stage.value = ScanStage.inProgress;
    activeStepIndex.value = 0;
    stepCompleted.assignAll([false, false, false, false, false]);
    detectedAccounts.clear();

    // Step 0: Getting started
    await Future.delayed(const Duration(milliseconds: 700));
    stepCompleted[0] = true;
    activeStepIndex.value = 1;

    // Step 1: Scanning inbox messages (Native fetch)
    await smsService.loadSms();
    await Future.delayed(const Duration(milliseconds: 900));
    stepCompleted[1] = true;
    activeStepIndex.value = 2;

    // Step 2: Analyzing transaction alerts (TRAI Header + Account # Verification)
    await Future.delayed(const Duration(milliseconds: 900));
    final analysisResults = smsService.analyzeAndDetectBanks();
    stepCompleted[2] = true;
    activeStepIndex.value = 3;

    // Step 3: Verifying bank accounts
    await Future.delayed(const Duration(milliseconds: 800));
    stepCompleted[3] = true;
    activeStepIndex.value = 4;

    // Step 4: Finalizing
    await Future.delayed(const Duration(milliseconds: 700));
    stepCompleted[4] = true;

    // Evaluate results
    if (analysisResults.isNotEmpty) {
      detectedAccounts.assignAll(
        analysisResults.values.map(
          (res) => DetectedAccountItem(
            bankName: res.bankName,
            sender: res.sender,
            accountNumber: res.accountNumber,
            messageCount: res.messageCount,
            matchedBy: res.matchedBy,
            isSelected: true,
          ),
        ),
      );
      stage.value = ScanStage.found;
    } else {
      stage.value = ScanStage.notFound;
    }
  }

  void toggleSelection(int index) {
    if (index >= 0 && index < detectedAccounts.length) {
      final item = detectedAccounts[index];
      item.isSelected = !item.isSelected;
      detectedAccounts.refresh();
    }
  }

  void confirmAndContinue() {
    final homeController = HomeTabController.to;
    for (final acc in detectedAccounts.where((a) => a.isSelected)) {
      final accName = '${acc.bankName} (..${acc.accountNumber})';

      homeController.addAccount(
        AccountModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_${acc.accountNumber}',
          name: accName,
          bankName: acc.bankName,
          type: 'savings',
          address: acc.sender,
        ),
      );
    }
    Get.back();
  }

  void retryScan() {
    startScanningProcess();
  }

  void addManually() {
    showAddAccountBottomSheet();
  }

  void skipToHome() {
    Get.back();
  }
}
