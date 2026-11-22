import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:monvexa/models/sms_model.dart';

class BankDetectionResult {
  final String bankName;
  final String sender;
  final String accountNumber;
  final double latestBalance;
  final int messageCount;
  final String matchedBy;

  BankDetectionResult({
    required this.bankName,
    required this.sender,
    required this.accountNumber,
    required this.latestBalance,
    required this.messageCount,
    required this.matchedBy,
  });
}

class SmsService extends GetxService {
  static const MethodChannel _smsChannel = MethodChannel('com.monvexa/sms');
  static const MethodChannel _permChannel = MethodChannel('com.monvexa/permissions');
  static const EventChannel _liveChannel = EventChannel('com.monvexa/sms_live');

  final RxBool hasPermission = false.obs;
  final RxList<SmsModel> allMessages = <SmsModel>[].obs;

  StreamSubscription? _liveSub;
  final _liveSmsController = StreamController<SmsModel>.broadcast();
  Stream<SmsModel> get onLiveSms => _liveSmsController.stream;

  @override
  void onInit() {
    super.onInit();
    _initLiveListener();
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    _liveSmsController.close();
    super.onClose();
  }

  void _initLiveListener() {
    _liveSub = _liveChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map) {
        final sms = SmsModel.fromMap(Map<String, dynamic>.from(event));
        debugPrint('[LiveSMS] Intercepted new SMS from: ${sms.address}');
        allMessages.insert(0, sms);
        _liveSmsController.add(sms);
      }
    }, onError: (dynamic err) {
      debugPrint('[LiveSMS] Error: $err');
    });
  }

  /// Silent check on startup
  Future<void> checkPermissionSilently() async {
    final granted = await _permChannel.invokeMethod<bool>('hasSmsPermission') ?? false;
    hasPermission.value = granted;
    if (granted) await loadSms();
  }

  /// Shows Android system permission dialog
  Future<bool> requestPermission() async {
    final granted = await _permChannel.invokeMethod<bool>('requestSmsPermission') ?? false;
    hasPermission.value = granted;
    if (granted) await loadSms();
    return granted;
  }

  /// Opens Android App Info screen
  Future<void> openAppSettings() async {
    await _permChannel.invokeMethod<void>('openAppSettings');
  }

  Future<void> loadSms({int limit = 400}) async {
    debugPrint('-------------------------SMS Reading------------------');
    debugPrint('[SMS Reading] Process started...');
    debugPrint('[SMS Reading] Permission status: ${hasPermission.value}');

    try {
      final raw = await _smsChannel.invokeMethod<List<dynamic>>('getInboxSms', {'limit': limit});
      if (raw == null) {
        debugPrint('[SMS Reading] Received null from native channel.');
        return;
      }

      final parsed = raw.map((e) {
        return SmsModel.fromMap(Map<String, dynamic>.from(e as Map));
      }).toList();

      allMessages.assignAll(parsed);
      debugPrint('[SMS Reading] Fetched ${parsed.length} total SMS from inbox.');
    } catch (e, stack) {
      debugPrint('[SMS Reading] ERROR fetching SMS: $e');
      debugPrint('$stack');
    }
  }

  // ── TRAI Indian Bank Sender Codes ─────────────────────────────────
  static const Map<String, String> _traiBankSenderMap = {
    // Bank of Baroda
    'BOBSMS': 'Bank of Baroda',
    'BOBTXN': 'Bank of Baroda',
    'BARODA': 'Bank of Baroda',
    'BOBALT': 'Bank of Baroda',

    // South Indian Bank
    'SIBBNK': 'South Indian Bank',
    'SIBTRX': 'South Indian Bank',
    'SOINBK': 'South Indian Bank',
    'SIBANK': 'South Indian Bank',
    'SIBLTD': 'South Indian Bank',
    'SIBSMS': 'South Indian Bank',

    // State Bank of India
    'SBIINB': 'State Bank of India',
    'SBIPSG': 'State Bank of India',
    'SBISMS': 'State Bank of India',
    'SBICRD': 'SBI Card',
    'ATMSBI': 'State Bank of India',

    // HDFC Bank
    'HDFCBK': 'HDFC Bank',
    'HDFCBN': 'HDFC Bank',

    // ICICI Bank
    'ICICIB': 'ICICI Bank',
    'ICICIN': 'ICICI Bank',
    'ICICIT': 'ICICI Bank',

    // Axis Bank
    'AXISBK': 'Axis Bank',
    'AXISBN': 'Axis Bank',

    // Kotak Mahindra Bank
    'KOTAKB': 'Kotak Mahindra Bank',
    'KMBLBK': 'Kotak Mahindra Bank',

    // Punjab National Bank
    'PNBSMS': 'Punjab National Bank',
    'PNBBNK': 'Punjab National Bank',

    // Canara Bank
    'CANBNK': 'Canara Bank',
    'CANARA': 'Canara Bank',

    // Union Bank
    'UNIONB': 'Union Bank of India',
    'UBISMS': 'Union Bank of India',

    // Federal Bank
    'FEDBNK': 'Federal Bank',
    'FEDERA': 'Federal Bank',

    // IDFC FIRST Bank
    'IDFCFB': 'IDFC FIRST Bank',
    'IDFCBK': 'IDFC FIRST Bank',

    // IndusInd Bank
    'INDUSB': 'IndusInd Bank',

    // Yes Bank
    'YESBNK': 'Yes Bank',

    // Central Bank of India
    'CBISMS': 'Central Bank of India',

    // Indian Bank
    'IDIBNK': 'Indian Bank',

    // Bank of India
    'BOIIND': 'Bank of India',
    'BOISMS': 'Bank of India',
  };

  bool _isPromotionalOrTelecom(String sender) {
    final s = sender.toUpperCase().trim();
    if (s.endsWith('-P') || s.endsWith('_P')) return true;
    if (s.contains('AIRTEL') || s.contains('JIO') || s.contains('VI') || s.contains('BSNL')) return true;
    if (s.contains('SWIGGY') || s.contains('ZOMATO') || s.contains('FLIPKT') || s.contains('AMAZON')) return true;
    return false;
  }

  /// Public helper to resolve bank name from any TRAI sender code (e.g. BOBTXN, BOBSMS -> Bank of Baroda)
  String? resolveBankFromSender(String sender) => _resolveBankFromSenderHeader(sender);

  /// Public helper to extract account number from SMS body
  String? extractAccountNumberFromBody(String body) => _extractAccountNumber(body);

  String? _resolveBankFromSenderHeader(String sender) {
    if (_isPromotionalOrTelecom(sender)) return null;

    final headerUpper = sender.toUpperCase().trim();

    for (final entry in _traiBankSenderMap.entries) {
      if (headerUpper.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String? _extractAccountNumber(String body) {
    final accPatterns = [
      RegExp(r'(?:a/c|acct|account|acc)\s*(?:no\.?|ending)?\s*[:\-\s]*[x*]*(\d{3,6})\b', caseSensitive: false),
      RegExp(r'(?:a/c|acct|account)\s*[*xX]{2,}(\d{3,6})\b', caseSensitive: false),
      RegExp(r'\b[xX*]{2,}(\d{3,6})\b'),
      RegExp(r'card\s*(?:ending|no\.?)?\s*[:\-\s]*[x*]*(\d{4})\b', caseSensitive: false),
    ];

    for (final reg in accPatterns) {
      final match = reg.firstMatch(body);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }
    return null;
  }

  double? _extractAvailableBalance(String body) {
    final balPatterns = [
      // 1. "final balance is RS 12,450.00" / "final bal is Rs ..." / "balance is Rs ..."
      RegExp(r'(?:final|total|net|avail|available|clear|clr)?\s*bal(?:ance)?\s*(?:is|in\s+a/c\s+is)?\s*[:\-\s]*(?:rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
      // 2. "Rs 12,450.00 is available/balance"
      RegExp(r'(?:rs\.?|inr)\s*([\d,]+(?:\.\d{1,2})?)\s*(?:is\s+)?(?:final|avl|avail|available|clr|total)?\s*bal(?:ance)?\b', caseSensitive: false),
      // 3. Fallback for "Bal: Rs 1234.50" or "Bal Rs.12345"
      RegExp(r'\bbal\s*[:\-\s]*(?:rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    ];

    for (final reg in balPatterns) {
      final match = reg.firstMatch(body);
      if (match != null && match.group(1) != null) {
        final rawNum = match.group(1)!.replaceAll(',', '');
        final val = double.tryParse(rawNum);
        if (val != null) return val;
      }
    }
    return null;
  }

  bool _isTransactionalAlert(String body) {
    final lower = body.toLowerCase();

    if (lower.contains('pre-approved') ||
        lower.contains('apply now') ||
        lower.contains('loan offer') ||
        lower.contains('congratulations') ||
        lower.contains('claim your') ||
        lower.contains('get up to')) {
      return false;
    }

    final txKeywords = [
      'debited', 'credited', 'withdrawn', 'transferred', 'sent to', 'received from',
      'deposited', 'spent', 'avl bal', 'available bal', 'clr bal', 'ledger bal',
      'balance is', 'final balance', 'inr', 'rs.', 'neft', 'rtgs', 'imps', 'upi/cr', 'upi/dr'
    ];

    return txKeywords.any((kw) => lower.contains(kw));
  }

  Map<String, BankDetectionResult> analyzeAndDetectBanks() {
    debugPrint('-------------------------SMS Reading Analysis------------------');
    debugPrint('[SMS Reading] Analyzing ${allMessages.length} total messages with TRAI Header verification...');

    final Map<String, List<SmsModel>> accountMessages = {};
    final Map<String, String> accountSenders = {};

    int matchedCount = 0;
    int promoOrNonBankDiscarded = 0;
    int noAccountNumDiscarded = 0;

    for (final sms in allMessages) {
      final bankName = _resolveBankFromSenderHeader(sms.address);
      if (bankName == null) {
        promoOrNonBankDiscarded++;
        continue;
      }

      if (!_isTransactionalAlert(sms.body)) {
        continue;
      }

      final accNo = _extractAccountNumber(sms.body);
      if (accNo == null) {
        noAccountNumDiscarded++;
        continue;
      }

      final key = '$bankName|$accNo';
      accountMessages.putIfAbsent(key, () => []).add(sms);
      accountSenders[key] = sms.address;
      matchedCount++;
    }

    debugPrint('--- [Filtering Summary] ---');
    debugPrint('  • Discarded promos/non-bank headers: $promoOrNonBankDiscarded');
    debugPrint('  • Discarded alerts without account number: $noAccountNumDiscarded');
    debugPrint('  • Valid transactional alerts matched: $matchedCount');

    final results = <String, BankDetectionResult>{};

    debugPrint('-------------------------Account Balance Extraction------------------');
    accountMessages.forEach((key, list) {
      final parts = key.split('|');
      final bankName = parts[0];
      final accNo = parts[1];
      final sender = accountSenders[key] ?? list.first.address;

      // Sort by date descending to extract the latest available balance
      list.sort((a, b) => b.date.compareTo(a.date));

      double extractedBalance = 0.0;
      String sampleSnippet = '';

      for (final sms in list) {
        final bal = _extractAvailableBalance(sms.body);
        if (bal != null) {
          extractedBalance = bal;
          sampleSnippet = sms.body.replaceAll('\n', ' ');
          if (sampleSnippet.length > 70) sampleSnippet = sampleSnippet.substring(0, 70) + '...';
          break;
        }
      }

      debugPrint('Bank: $bankName (..$accNo) | Extracted Balance: ₹ $extractedBalance');
      if (sampleSnippet.isNotEmpty) {
        debugPrint('  • Source SMS snippet: "$sampleSnippet"');
      }

      results[key] = BankDetectionResult(
        bankName: bankName,
        sender: sender,
        accountNumber: accNo,
        latestBalance: extractedBalance,
        messageCount: list.length,
        matchedBy: 'TRAI Header + Account # Verification',
      );
    });
    debugPrint('---------------------------------------------------------------------');

    return results;
  }
}
