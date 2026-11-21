import 'dart:async';
import 'package:get/get.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/models/account_model.dart';
import 'package:monvexa/services/database_service.dart';
import 'package:monvexa/services/sms_service.dart';

enum ScanStage { inProgress, found, notFound }

class DetectedAccountItem {
  final String bankName;
  final String sender;
  final String accountNumber;
  final int messageCount;
  final double balance;
  final String matchedBy;
  bool isSelected;

  DetectedAccountItem({
    required this.bankName,
    required this.sender,
    required this.accountNumber,
    required this.messageCount,
    required this.balance,
    required this.matchedBy,
    this.isSelected = true,
  });
}

class AccountDetectionController extends GetxController {
  final SmsService smsService = Get.find<SmsService>();

  final Rx<ScanStage> stage = ScanStage.inProgress.obs;
  final RxInt activeStepIndex = 0.obs;
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
    await Future.delayed(const Duration(milliseconds: 600));
    stepCompleted[0] = true;
    activeStepIndex.value = 1;

    // Step 1: Scanning inbox messages (Native fetch)
    await smsService.loadSms();
    await Future.delayed(const Duration(milliseconds: 700));
    stepCompleted[1] = true;
    activeStepIndex.value = 2;

    // Step 2: Analyzing transaction alerts
    await Future.delayed(const Duration(milliseconds: 700));
    final analysisResults = smsService.analyzeAndDetectBanks();
    stepCompleted[2] = true;
    activeStepIndex.value = 3;

    // Step 3: Verifying which accounts are NEW (Delta detection from SQLite)
    await Future.delayed(const Duration(milliseconds: 600));
    final existingAccounts = await DatabaseService.to.getAccounts();
    stepCompleted[3] = true;
    activeStepIndex.value = 4;

    // Step 4: Finalizing
    await Future.delayed(const Duration(milliseconds: 500));
    stepCompleted[4] = true;

    // Filter out accounts that already exist in SQLite
    final List<DetectedAccountItem> newOnlyAccounts = [];

    for (final res in analysisResults.values) {
      final alreadySaved = existingAccounts.any(
        (acc) =>
            acc.bankName.toLowerCase() == res.bankName.toLowerCase() &&
            acc.accountNumber == res.accountNumber,
      );

      if (!alreadySaved) {
        newOnlyAccounts.add(
          DetectedAccountItem(
            bankName: res.bankName,
            sender: res.sender,
            accountNumber: res.accountNumber,
            balance: res.latestBalance,
            messageCount: res.messageCount,
            matchedBy: res.matchedBy,
            isSelected: true,
          ),
        );
      }
    }

    if (newOnlyAccounts.isNotEmpty) {
      detectedAccounts.assignAll(newOnlyAccounts);
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

  Future<void> confirmAndContinue() async {
    final homeController = HomeTabController.to;

    // Save ONLY checked accounts into SQLite
    final checkedList = detectedAccounts.where((a) => a.isSelected).toList();

    for (final acc in checkedList) {
      final accName = '${acc.bankName} (..${acc.accountNumber})';

      final model = AccountModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_${acc.accountNumber}',
        name: accName,
        bankName: acc.bankName,
        accountNumber: acc.accountNumber,
        balance: acc.balance,
        type: 'savings',
        address: acc.sender,
      );

      await homeController.addAccount(model);
    }

    Get.back();
  }

  void retryScan() {
    startScanningProcess();
  }

  void skipToHome() {
    Get.back();
  }
}
