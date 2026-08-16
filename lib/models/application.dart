class Application {
  final String id;
  final String offerId;
  final String applicantName; // ajustar según lo que devuelva el API
  final String comment;
  final String status; // en_revision | descartado | finalista | ganador
  final double? rating;

  Application({
    required this.id,
    required this.offerId,
    required this.applicantName,
    required this.comment,
    required this.status,
    this.rating,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'].toString(),
      offerId: json['offer_id'].toString(),
      applicantName: json['applicant_name'] ?? '',
      comment: json['comment'] ?? '',
      status: json['status'] ?? 'en_revision',
      rating: json['rating']?.toDouble(),
    );
  }
}