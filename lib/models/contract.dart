class ContractParty {
  final String id;
  final String? name;

  ContractParty({required this.id, this.name});

  factory ContractParty.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ContractParty(id: '');
    return ContractParty(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString(),
    );
  }
}

class Contract {
  final String id;
  final String offerId;
  final String? jobTypeName;
  final ContractParty contratante;
  final ContractParty contratado;
  final String? myRole; // ej. "contratante" | "contratado"
  final double? salary;
  final String? currency;
  final DateTime? startDate;
  final String? duration;
  final String? status;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final String? cancelJustification;
  final ContractParty? cancelledBy;
  final DateTime? cancelledAt;

  Contract({
    required this.id,
    required this.offerId,
    this.jobTypeName,
    required this.contratante,
    required this.contratado,
    this.myRole,
    this.salary,
    this.currency,
    this.startDate,
    this.duration,
    this.status,
    this.createdAt,
    this.acceptedAt,
    this.cancelJustification,
    this.cancelledBy,
    this.cancelledAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: (json['id'] ?? '').toString(),
      offerId: (json['offerId'] ?? '').toString(),
      jobTypeName: json['jobTypeName']?.toString(),
      contratante: ContractParty.fromJson(json['contratante']),
      contratado: ContractParty.fromJson(json['contratado']),
      myRole: json['myRole']?.toString(),
      salary: json['salary'] != null ? (json['salary'] as num).toDouble() : null,
      currency: json['currency']?.toString(),
      startDate:
          json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      duration: json['duration']?.toString(),
      status: json['status']?.toString(),
      createdAt:
          json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      acceptedAt:
          json['acceptedAt'] != null ? DateTime.tryParse(json['acceptedAt']) : null,
      cancelJustification: json['cancelJustification']?.toString(),
      cancelledBy: json['cancelledBy'] != null
          ? ContractParty.fromJson(json['cancelledBy'])
          : null,
      cancelledAt:
          json['cancelledAt'] != null ? DateTime.tryParse(json['cancelledAt']) : null,
    );
  }
}