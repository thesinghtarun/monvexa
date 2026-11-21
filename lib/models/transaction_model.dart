enum TransactionType { credit, debit }

class TransactionModel {
  final String id;
  final String accountId;
  final String bankName;
  final String accountNumber;
  final String address;
  final double amount;
  final double balance;
  final TransactionType type;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String rawBody;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.bankName,
    required this.accountNumber,
    required this.address,
    required this.amount,
    this.balance = 0.0,
    required this.type,
    required this.title,
    required this.description,
    this.category = 'general',
    required this.date,
    this.rawBody = '',
  });

  bool get isCredit => type == TransactionType.credit;
  bool get isDebit => type == TransactionType.debit;

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'] as String,
        accountId: (map['accountId'] as String?) ?? '',
        bankName: (map['bankName'] as String?) ?? '',
        accountNumber: (map['accountNumber'] as String?) ?? '',
        address: (map['address'] as String?) ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
        type: (map['type'] as String?) == 'credit'
            ? TransactionType.credit
            : TransactionType.debit,
        title: (map['title'] as String?) ?? '',
        description: (map['description'] as String?) ?? '',
        category: (map['category'] as String?) ?? 'general',
        date: DateTime.fromMillisecondsSinceEpoch(
          (map['timestamp'] as num?)?.toInt() ?? 0,
        ),
        rawBody: (map['rawBody'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'accountId': accountId,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'address': address,
        'amount': amount,
        'balance': balance,
        'type': type == TransactionType.credit ? 'credit' : 'debit',
        'title': title,
        'description': description,
        'category': category,
        'timestamp': date.millisecondsSinceEpoch,
        'rawBody': rawBody,
      };
}
