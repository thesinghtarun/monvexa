import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/models/account_model.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/services/pref_service.dart';
import 'package:monvexa/services/sms_service.dart';
import 'package:monvexa/widgets/home_tab/permission_denied_dialog.dart';

/// UI state values:
///   'loading'          -> spinner shown (only during active async ops)
///   'noAccount'        -> empty state: account card + no account msg + add button
///   'ready'            -> normal home with AccountCard + transactions
class HomeTabController extends GetxController {
  static HomeTabController get to => Get.find<HomeTabController>();

  final SmsService smsService = Get.find<SmsService>();

  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final Rx<AccountModel?> active = Rx<AccountModel?>(null);
  final RxString uiState = 'noAccount'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAccountsFromPrefs();
    uiState.value = accounts.isNotEmpty ? 'ready' : 'noAccount';

    // Safely trigger permission flow after first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPermissionFlow();
    });
  }

  void _loadAccountsFromPrefs() {
    accounts.assignAll(PrefService.to.getAccounts());
    final id = PrefService.to.activeAccountId;
    active.value = accounts.firstWhereOrNull((a) => a.id == id) ??
        accounts.firstOrNull;
  }

  Future<void> _initPermissionFlow() async {
    // 1. Check existing permission status
    await smsService.checkPermissionSilently();

    if (smsService.hasPermission.value) {
      if (accounts.isEmpty) {
        _openAccountDetection();
      } else {
        uiState.value = 'ready';
      }
      return;
    }

    // 2. Request permission (shows Android system dialog)
    final granted = await smsService.requestPermission();

    if (granted) {
      if (accounts.isEmpty) {
        _openAccountDetection();
      } else {
        uiState.value = 'ready';
      }
    } else {
      // Denied — show our custom glass dialog
      _showPermissionDeniedDialog();
      uiState.value = 'noAccount';
    }
  }

  void _openAccountDetection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(AppRoutes.accountDetection)?.then((_) {
        _loadAccountsFromPrefs();
        uiState.value = accounts.isNotEmpty ? 'ready' : 'noAccount';
      });
    });
  }

  // Called when returning with accounts
  void onAccountsReady() {
    _loadAccountsFromPrefs();
    uiState.value = accounts.isNotEmpty ? 'ready' : 'noAccount';
  }

  // ── Permission dialog callbacks ──────────────────────────────────
  void _showPermissionDeniedDialog() {
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
    uiState.value = 'noAccount';
  }

  void onPermissionDialogOpenSettings() {
    Get.back();
    smsService.openAppSettings();
    uiState.value = 'noAccount';
  }

  // ── Account management ───────────────────────────────────────────
  void addAccount(AccountModel account) {
    accounts.add(account);
    PrefService.to.saveAccounts(accounts);
    setActive(account);
    uiState.value = 'ready';
  }

  void setActive(AccountModel account) {
    active.value = account;
    PrefService.to.setActiveAccount(account.id);
  }

  String get activeAccountName =>
      active.value?.name ?? 'Add Account';

  String get activeAccountBank =>
      active.value?.bankName ?? '';

  // ── Transactions for active account ─────────────────────────────
  List<dynamic> get activeTransactions {
    if (active.value == null || active.value!.address.isEmpty) return [];
    return smsService.allMessages
        .where((m) => m.address == active.value!.address)
        .toList();
  }
}
