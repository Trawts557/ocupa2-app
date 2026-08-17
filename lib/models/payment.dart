class Payment {
  final String id;
  final String offerId;
  final double amount;
  final String currency; // Asegúrate de tener la moneda si la usas
  final String period;   // Añade esta línea
  final String status;
  final DateTime date;

  Payment({
    required this.id,
    required this.offerId,
    required this.amount,
    required this.currency,
    required this.period,
    required this.status,
    required this.date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'].toString(),
      offerId: json['offer_id'].toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      period: json['period'] ?? json['periodicity'] ?? '', // Lee el período del JSON
      status: json['status'] ?? '',
      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}