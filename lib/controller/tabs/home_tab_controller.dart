import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/models/account_model.dart';
import 'package:monvexa/models/sms_model.dart';
import 'package:monvexa/models/transaction_model.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/services/database_service.dart';
import 'package:monvexa/services/pref_service.dart';
import 'package:monvexa/services/sms_service.dart';
import 'package:monvexa/services/ad_service.dart';
import 'package:monvexa/utils/sms_transaction_parser.dart';
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
  final RxBool showBal = false.obs;

  // Transactions state
  final RxList<TransactionModel> recentFiveTransactions = <TransactionModel>[].obs;
  final RxDouble todayCreditAmount = 0.0.obs;
  final RxDouble todayDebitAmount = 0.0.obs;
  final RxList<FlSpot> todayChartSpots = <FlSpot>[].obs;

  StreamSubscription<SmsModel>? _liveSmsSub;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadAccountsFromDb();

    if (Get.isRegistered<AdService>()) {
      AdService.to.startHomeTimer();
    }

    _liveSmsSub = smsService.onLiveSms.listen((sms) {
      _handleIncomingLiveSms(sms);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPermissionAndPrompt();
    });
  }

  @override
  void onClose() {
    if (Get.isRegistered<AdService>()) {
      AdService.to.stopHomeTimer();
    }
    _liveSmsSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Get.isRegistered<AdService>()) {
        AdService.to.startHomeTimer();
      }
      handleAppResume();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (Get.isRegistered<AdService>()) {
        AdService.to.stopHomeTimer();
      }
    }
  }

  Future<void> handleAppResume() async {
    await smsService.checkPermissionSilently();

    if (smsService.hasPermission.value) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      await loadAccountsFromDb();

      if (accounts.isEmpty) {
        openAccountDetection();
      } else {
        uiState.value = 'ready';
        await syncAndRefreshTransactions();
      }
    } else {
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

    if (active.value != null) {
      await syncAndRefreshTransactions();
    }
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

    final granted = await smsService.requestPermission();

    if (granted) {
      await loadAccountsFromDb();
      if (accounts.isEmpty) {
        openAccountDetection();
      } else {
        uiState.value = 'ready';
      }
    } else {
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

  void setActive(AccountModel account) async {
    // Reload fresh account state from SQLite in case it was updated in the background
    final list = await DatabaseService.to.getAccounts();
    accounts.assignAll(list);
    final fresh = list.firstWhereOrNull((a) => a.id == account.id) ?? account;

    active.value = fresh;
    PrefService.to.setActiveAccount(fresh.id);
    await syncAndRefreshTransactions();
  }

  String get activeAccountName => active.value?.name ?? 'Add Account';
  String get activeAccountBank => active.value?.bankName ?? '';

  /// Helper to check if an SMS strictly belongs to an account:
  /// 1. Bank TRAI code must match the account's bank name (e.g. BOBSMS, BOBTXN, BOBALT -> Bank of Baroda).
  /// 2. SMS body must explicitly contain the account number digits (e.g. 3339).
  bool _smsMatchesAccount(SmsModel sms, AccountModel acc) {
    final bankFromSender = smsService.resolveBankFromSender(sms.address);
    if (bankFromSender == null) return false;

    final isSameBank = bankFromSender.toLowerCase() == acc.bankName.toLowerCase();
    if (!isSameBank) return false;

    if (acc.accountNumber.isNotEmpty) {
      return sms.body.contains(acc.accountNumber);
    }
    return true;
  }

  // ── Isolated Live SMS Handler ──────────────────────────────────────
  Future<void> _handleIncomingLiveSms(SmsModel sms) async {
    // Check which account this incoming SMS strictly belongs to
    AccountModel? target;
    for (final acc in accounts) {
      if (_smsMatchesAccount(sms, acc)) {
        target = acc;
        break;
      }
    }

    if (target == null) return;

    final parsed = SmsTransactionParser.parseSms(
      sms,
      accountId: target.id,
      bankName: target.bankName,
      matchedAccountNumber: target.accountNumber,
    );

    if (parsed != null) {
      // 1. Asynchronously archive into SQLite for future reports (non-blocking)
      DatabaseService.to.insertTransactions([parsed]);

      // 2. If SMS includes final balance, update account in SQLite and in-memory list
      if (parsed.balance > 0) {
        final updated = AccountModel(
          id: target.id,
          name: target.name,
          bankName: target.bankName,
          accountNumber: target.accountNumber,
          balance: parsed.balance,
          type: target.type,
          address: target.address,
          createdAt: target.createdAt,
        );
        DatabaseService.to.insertAccount(updated);

        final idx = accounts.indexWhere((a) => a.id == target!.id);
        if (idx != -1) accounts[idx] = updated;

        if (active.value?.id == target.id) {
          active.value = updated;
        }
      }

      // 3. Immediately refresh in-memory state so UI updates in real-time
      if (active.value?.id == target.id) {
        await syncAndRefreshTransactions();
      }
    }
  }

  // ── Direct In-Memory SMS Transaction & Balance Pipeline ───────────
  Future<void> syncAndRefreshTransactions() async {
    final currentActive = active.value;
    if (currentActive == null) return;

    // 1. Filter ALL messages in memory that strictly match Bank + Account Number
    final matchingMessages = smsService.allMessages.where((sms) {
      return _smsMatchesAccount(sms, currentActive);
    }).toList();

    // 2. Parse all into TransactionModels
    final List<TransactionModel> parsedTransactions = [];
    for (final sms in matchingMessages) {
      final parsed = SmsTransactionParser.parseSms(
        sms,
        accountId: currentActive.id,
        bankName: currentActive.bankName,
        matchedAccountNumber: currentActive.accountNumber,
      );
      if (parsed != null) {
        parsedTransactions.add(parsed);
      }
    }

    // 3. Sort strictly by date descending (newest transactions first)
    parsedTransactions.sort((a, b) => b.date.compareTo(a.date));

    // 4. Update the Recent 5 Transactions DIRECTLY from the newest SMS
    recentFiveTransactions.assignAll(parsedTransactions.take(5).toList());

    // 5. Update Balance directly from the most recent balance-bearing transaction SMS
    for (final txn in parsedTransactions) {
      if (txn.balance > 0) {
        if (currentActive.balance != txn.balance) {
          final updatedAccount = AccountModel(
            id: currentActive.id,
            name: currentActive.name,
            bankName: currentActive.bankName,
            accountNumber: currentActive.accountNumber,
            balance: txn.balance,
            type: currentActive.type,
            address: currentActive.address,
            createdAt: currentActive.createdAt,
          );
          active.value = updatedAccount;
          final idx = accounts.indexWhere((a) => a.id == currentActive.id);
          if (idx != -1) accounts[idx] = updatedAccount;
          DatabaseService.to.insertAccount(updatedAccount);
        }
        break;
      }
    }

    // 6. Calculate Today's Income, Expense, and Graph (all transactions today, not limited to 5)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    final todayTransactions = parsedTransactions.where((t) {
      final tEpoch = t.date.millisecondsSinceEpoch;
      return tEpoch >= todayStart && tEpoch <= todayEnd;
    }).toList();

    // Sort today transactions chronologically (oldest to newest) for line graph progression
    todayTransactions.sort((a, b) => a.date.compareTo(b.date));

    double creditSum = 0.0;
    double debitSum = 0.0;
    final List<FlSpot> spots = [];

    for (final txn in todayTransactions) {
      if (txn.isCredit) {
        creditSum += txn.amount;
      } else {
        debitSum += txn.amount;
      }
    }

    // Only generate graph spots if there was actual transaction activity today
    if (todayTransactions.isNotEmpty) {
      final currentBalance = active.value?.balance ?? 0.0;
      // Opening balance at start of today (before today's debits/credits)
      final openingBalance = currentBalance + debitSum - creditSum;

      // Point 0: Day's Opening Balance baseline
      spots.add(FlSpot(0, openingBalance));

      // Points 1..N: Progression after each transaction today
      double runningBalance = openingBalance;
      for (int i = 0; i < todayTransactions.length; i++) {
        final txn = todayTransactions[i];
        if (txn.isCredit) {
          runningBalance += txn.amount;
        } else {
          runningBalance -= txn.amount;
        }
        spots.add(FlSpot(
          (i + 1).toDouble(),
          txn.balance > 0 ? txn.balance : runningBalance,
        ));
      }
    }

    todayCreditAmount.value = creditSum;
    todayDebitAmount.value = debitSum;
    todayChartSpots.assignAll(spots);

    // 7. Background SQLite archival for future reports (non-blocking)
    if (parsedTransactions.isNotEmpty) {
      DatabaseService.to.insertTransactions(parsedTransactions);
    }
  }

  // UI Related
  void toggleShowBal() {
    showBal.value = !showBal.value;
  }
}
