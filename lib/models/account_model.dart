class AccountModel {
  final String id;
  final String name;
  final String bankName;
  final String type; // 'personal' | 'savings' | 'business'
  final String address; // SMS sender ID, empty if manually added

  AccountModel({
    required this.id,
    required this.name,
    required this.bankName,
    required this.type,
    this.address = '',
  });

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
        id: j['id'] as String,
        name: j['name'] as String,
        bankName: j['bankName'] as String,
        type: j['type'] as String,
        address: (j['address'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bankName': bankName,
        'type': type,
        'address': address,
      };
}
