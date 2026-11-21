import 'dart:convert';
import 'package:get/get.dart';
import 'package:monvexa/models/account_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  static PrefService get to => Get.find<PrefService>();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Onboarding ───────────────────────────────────────────────────
  bool get isOnboardingDone => _prefs.getBool('onboarding_done') ?? false;
  Future<void> setOnboardingDone() => _prefs.setBool('onboarding_done', true);

  // ── Active Account ───────────────────────────────────────────────
  String? get activeAccountId => _prefs.getString('active_account_id');
  Future<void> setActiveAccount(String id) =>
      _prefs.setString('active_account_id', id);

  // ── Accounts (JSON list) ─────────────────────────────────────────
  List<AccountModel> getAccounts() {
    final raw = _prefs.getStringList('accounts_json') ?? [];
    return raw
        .map((e) => AccountModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAccounts(List<AccountModel> list) =>
      _prefs.setStringList(
        'accounts_json',
        list.map((a) => jsonEncode(a.toJson())).toList(),
      );
}
