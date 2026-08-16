class Offer {
  final String id;
  final String jobTypeId;
  final String contractType; // temporal | fijo | por_horas
  final double latitude;
  final double longitude;
  final String address;
  final double pay;
  final String description;
  final String photoUrl;
  final DateTime deadline;
  final bool active;

  Offer({
    required this.id,
    required this.jobTypeId,
    required this.contractType,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.pay,
    required this.description,
    required this.photoUrl,
    required this.deadline,
    required this.active,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'].toString(),
      jobTypeId: json['job_type_id'].toString(),
      contractType: json['contract_type'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      pay: (json['pay'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      deadline: DateTime.tryParse(json['deadline'] ?? '') ?? DateTime.now(),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_type_id': jobTypeId,
      'contract_type': contractType,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'pay': pay,
      'description': description,
      'photo_url': photoUrl,
      'deadline': deadline.toIso8601String(),
    };
  }
}