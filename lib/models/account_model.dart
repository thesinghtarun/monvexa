class AccountModel {
  final String id;
  final String name;
  final String bankName;
  final String accountNumber;
  final double balance;
  final String type; // 'personal' | 'savings' | 'business'
  final String address; // SMS sender ID e.g. "BOBSMS"
  final int createdAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.bankName,
    this.accountNumber = '',
    this.balance = 0.0,
    required this.type,
    this.address = '',
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory AccountModel.fromMap(Map<String, dynamic> map) => AccountModel(
        id: map['id'] as String,
        name: map['name'] as String,
        bankName: map['bankName'] as String,
        accountNumber: (map['accountNumber'] as String?) ?? '',
        balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
        type: (map['type'] as String?) ?? 'savings',
        address: (map['address'] as String?) ?? '',
        createdAt: (map['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'balance': balance,
        'type': type,
        'address': address,
        'createdAt': createdAt,
      };

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel.fromMap(j);

  Map<String, dynamic> toJson() => toMap();
}
