import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/models/account_model.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/services/database_service.dart';
import 'package:monvexa/services/pref_service.dart';
import 'package:monvexa/services/sms_service.dart';
import 'package:monvexa/widgets/home_tab/permission_denied_dialog.dart';

/// UI state values:
///   'loading'          -> spinner shown
///   'noAccount'        -> empty state: account card + no account msg
///   'ready'            -> normal home with AccountCard + transactions
class HomeTabController extends GetxController with WidgetsBindingObserver {
  static HomeTabController get to => Get.find<HomeTabController>();

  final SmsService smsService = Get.find<SmsService>();

  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final Rx<AccountModel?> active = Rx<AccountModel?>(null);
  final RxString uiState = 'noAccount'.obs;
  RxBool showBal = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadAccountsFromDb();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPermissionAndPrompt();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permission immediately when returning from Android Settings
      handleAppResume();
    }
  }

  Future<void> handleAppResume() async {
    await smsService.checkPermissionSilently();

    if (smsService.hasPermission.value) {
      // Permission granted in settings! Dismiss dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      await loadAccountsFromDb();

      if (accounts.isEmpty) {
        openAccountDetection();
      } else {
        uiState.value = 'ready';
      }
    } else {
      // Still denied in settings — show our custom permission dialog again
      showCustomPermissionDialog();
    }
  }

  Future<void> loadAccountsFromDb() async {
    final list = await DatabaseService.to.getAccounts();
    accounts.assignAll(list);

    final savedActiveId = PrefService.to.activeAccountId;
    active.value =
        accounts.firstWhereOrNull((a) => a.id == savedActiveId) ??
        accounts.firstOrNull;

    uiState.value = accounts.isNotEmpty ? 'ready' : 'noAccount';
  }

  Future<void> checkPermissionAndPrompt() async {
    await smsService.checkPermissionSilently();

    if (smsService.hasPermission.value) {
      await loadAccountsFromDb();

      if (accounts.isEmpty) {
        openAccountDetection();
      } else {
        uiState.value = 'ready';
      }
      return;
    }

    // Request native permission dialog
    final granted = await smsService.requestPermission();

    if (granted) {
      await loadAccountsFromDb();
      if (accounts.isEmpty) {
        openAccountDetection();
      } else {
        uiState.value = 'ready';
      }
    } else {
      // Denied — show our custom glass permission dialog
      showCustomPermissionDialog();
      uiState.value = accounts.isNotEmpty ? 'ready' : 'noAccount';
    }
  }

  void openAccountDetection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(AppRoutes.accountDetection)?.then((_) async {
        await loadAccountsFromDb();
      });
    });
  }

  void showCustomPermissionDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          PermissionDeniedDialogFactory.build(),
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
        );
      }
    });
  }

  void onPermissionDialogCancel() {
    Get.back();
    uiState.value = accounts.isNotEmpty ? 'ready' : 'noAccount';
  }

  void onPermissionDialogOpenSettings() {
    Get.back();
    smsService.openAppSettings();
  }

  // ── Account management (SQLite + SharedPrefs) ─────────────────────
  Future<void> addAccount(AccountModel account) async {
    await DatabaseService.to.insertAccount(account);
    await loadAccountsFromDb();
    setActive(account);
  }

  void setActive(AccountModel account) {
    active.value = account;
    // Persist selected active account ID in SharedPreferences
    PrefService.to.setActiveAccount(account.id);
  }

  String get activeAccountName => active.value?.name ?? 'Add Account';
  String get activeAccountBank => active.value?.bankName ?? '';

  List<dynamic> get activeTransactions {
    if (active.value == null || active.value!.address.isEmpty) return [];
    return smsService.allMessages
        .where((m) => m.address == active.value!.address)
        .toList();
  }

  //UI Related
  void toggleShowBal() {
    showBal.value = !showBal.value;
  }
}
