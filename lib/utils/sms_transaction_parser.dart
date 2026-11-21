import 'package:monvexa/models/sms_model.dart';
import 'package:monvexa/models/transaction_model.dart';

class SmsTransactionParser {
  /// Regular expressions to extract credit vs debit
  static final RegExp _creditRegExp = RegExp(
    r'\b(credited|credit|deposited|deposit|received|refund|reversed|added|cr)\b',
    caseSensitive: false,
  );

  static final RegExp _debitRegExp = RegExp(
    r'\b(debited|debit|spent|paid|withdrawn|dr|deducted|purchase|sent)\b',
    caseSensitive: false,
  );

  /// Transaction amount pattern (e.g., Rs. 500, INR 1,200.50, Rs 50.00)
  static final RegExp _amountRegExp = RegExp(
    r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  /// Account number pattern (e.g., a/c ..3339, a/c ending 1234, acc no. XX1234)
  static final RegExp _accountRegExp = RegExp(
    r'(?:a\/c|ac|acc(?:ount)?)\s*(?:no\.?|number)?\s*(?:ending\s*)?(?:[*xX\-]*\s*)+(\d{3,6})\b',
    caseSensitive: false,
  );

  /// Balance extraction pattern
  static final RegExp _balanceRegExp = RegExp(
    r'(?:final\s+bal(?:ance)?\s+is\s+(?:rs\.?|inr|₹)?|avail(?:able)?\s+bal(?:ance)?\s*(?:is)?\s*(?:rs\.?|inr|₹)?|clear\s+bal(?:ance)?\s*(?:is)?\s*(?:rs\.?|inr|₹)?|bal(?:ance)?\s*(?:is)?\s*(?:rs\.?|inr|₹)?)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  /// Extract a clean payee/merchant title
  static String extractMerchant(String body) {
    // 1. UPI payee e.g. "UPI/P2M/.../Swiggy" or "UPI/P2A/.../Tarun" or "VPA swiggy@icici"
    final upiVpaMatch = RegExp(r'(?:to\s+VPA|vpa|to\s+upi\s+id)\s+([a-zA-Z0-9.\-_@]+)', caseSensitive: false).firstMatch(body);
    if (upiVpaMatch != null && upiVpaMatch.group(1) != null) {
      final vpa = upiVpaMatch.group(1)!;
      final handle = vpa.split('@').first;
      return _cleanMerchantName(handle);
    }

    // 2. UPI slash formatted string (e.g. UPI/123456789/Swiggy or UPI/REF/Name)
    final upiSlashMatch = RegExp(r'UPI(?:\/CR|\/DR)?\/\d+\/([a-zA-Z0-9\s._\-]+?)(?:\/|\s|$)', caseSensitive: false).firstMatch(body);
    if (upiSlashMatch != null && upiSlashMatch.group(1) != null) {
      final name = upiSlashMatch.group(1)!.trim();
      if (name.isNotEmpty && name.length > 2) {
        return _cleanMerchantName(name);
      }
    }

    // 3. at <Merchant> (e.g. "at SWIGGY BANGALORE", "at AMAZON PAY", "at STARBUCKS")
    final atMatch = RegExp(r'\bat\s+([A-Za-z0-9\s&.\-_]+?)(?:\s+on|\s+dt|\s+ref|\.|\s*$)', caseSensitive: false).firstMatch(body);
    if (atMatch != null && atMatch.group(1) != null) {
      final m = atMatch.group(1)!.trim();
      if (m.isNotEmpty && m.length < 35 && !m.toLowerCase().startsWith('rs')) {
        return _cleanMerchantName(m);
      }
    }

    // 4. to <Beneficiary> (e.g. "transferred to John Doe", "sent to Tarun")
    final toMatch = RegExp(r'(?:to|transferred to|sent to)\s+([A-Za-z\s]+?)(?:\s+on|\s+ref|\.|\s*$)', caseSensitive: false).firstMatch(body);
    if (toMatch != null && toMatch.group(1) != null) {
      final payee = toMatch.group(1)!.trim();
      if (payee.isNotEmpty && payee.length < 30 && !payee.toLowerCase().contains('account')) {
        return _cleanMerchantName(payee);
      }
    }

    // 5. ATM Cash Withdrawal
    if (body.toLowerCase().contains('atm') || body.toLowerCase().contains('cash wdl')) {
      return 'ATM Cash Withdrawal';
    }

    // 6. Generic Fallbacks based on keywords
    if (body.toLowerCase().contains('salary')) return 'Salary Deposit';
    if (body.toLowerCase().contains('interest')) return 'Interest Credited';
    if (body.toLowerCase().contains('bill') || body.toLowerCase().contains('recharge')) return 'Bill Payment';
    if (body.toLowerCase().contains('refund')) return 'Merchant Refund';

    return 'Bank Transfer';
  }

  static String _cleanMerchantName(String name) {
    // Remove digits, extra symbols, uppercase first letters
    var cleaned = name.replaceAll(RegExp(r'[^a-zA-Z0-9\s&]'), ' ').trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return 'Bank Transfer';
    
    // Capitalize words
    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Parses a single SMS into a TransactionModel (or null if not a valid financial transaction)
  static TransactionModel? parseSms(
    SmsModel sms, {
    String? accountId,
    String? bankName,
    String? matchedAccountNumber,
  }) {
    final body = sms.body;

    // Must have an amount
    final amountMatch = _amountRegExp.firstMatch(body);
    if (amountMatch == null) return null;

    final rawAmountStr = amountMatch.group(1)?.replaceAll(',', '') ?? '0';
    final amount = double.tryParse(rawAmountStr) ?? 0.0;
    if (amount <= 0) return null;

    // Determine Credit vs Debit
    final hasDebit = _debitRegExp.hasMatch(body);
    final hasCredit = _creditRegExp.hasMatch(body);

    if (!hasDebit && !hasCredit) return null;

    final type = hasCredit && !hasDebit
        ? TransactionType.credit
        : TransactionType.debit;

    // Extract Account Number if not provided
    var accNum = matchedAccountNumber ?? '';
    if (accNum.isEmpty) {
      final accMatch = _accountRegExp.firstMatch(body);
      if (accMatch != null && accMatch.group(1) != null) {
        accNum = accMatch.group(1)!;
      }
    }

    // Extract Balance if mentioned
    double balance = 0.0;
    final balMatch = _balanceRegExp.firstMatch(body);
    if (balMatch != null && balMatch.group(1) != null) {
      final balStr = balMatch.group(1)!.replaceAll(',', '');
      balance = double.tryParse(balStr) ?? 0.0;
    }

    // Generate merchant and clean description
    final title = extractMerchant(body);
    final description = accNum.isNotEmpty
        ? 'A/c ••$accNum'
        : (bankName ?? 'Bank Alert');

    // Create a stable deterministic ID from address + timestamp + amount
    final stableId = '${sms.address}_${sms.date.millisecondsSinceEpoch}_${amount.toInt()}';

    return TransactionModel(
      id: stableId,
      accountId: accountId ?? '',
      bankName: bankName ?? '',
      accountNumber: accNum,
      address: sms.address,
      amount: amount,
      balance: balance,
      type: type,
      title: title,
      description: description,
      date: sms.date,
      rawBody: body,
    );
  }
}
