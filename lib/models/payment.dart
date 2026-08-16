class Payment {
  final String id;
  final String offerId;
  final double amount;
  final String status;
  final DateTime date;

  Payment({
    required this.id,
    required this.offerId,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'].toString(),
      offerId: json['offer_id'].toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}