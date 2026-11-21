class SmsModel {
  final String id;
  final String address; // sender short code e.g. "VM-HDFCBK"
  final String body;
  final DateTime date;

  SmsModel({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
  });

  factory SmsModel.fromMap(Map<String, dynamic> m) => SmsModel(
        id: m['id']?.toString() ?? '',
        address: m['address']?.toString() ?? '',
        body: m['body']?.toString() ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(
            (m['date'] as num?)?.toInt() ?? 0),
      );
}
