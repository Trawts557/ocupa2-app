class CreateOfferRequest {
  final String jobTypeId;
  final String contractType; // temporal | fijo | por_horas
  final double latitude;
  final double longitude;
  final String address;
  final double pay;
  final String description;
  final String photoUrl;
  final DateTime deadline;

  CreateOfferRequest({
    required this.jobTypeId,
    required this.contractType,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.pay,
    required this.description,
    required this.photoUrl,
    required this.deadline,
  });

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