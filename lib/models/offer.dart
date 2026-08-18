class Offer {
  final String id;
  final String jobTypeKey;
  final String jobTypeName;
  final String contractType;
  final String description;
  final String address;
  final Location location;
  final Payment payment;
  final String? photo;
  final DateTime? deadline;
  final List<dynamic> customAnswers;
  final List<OfferQuestion> questions;

  Offer({
    required this.id,
    required this.jobTypeKey,
    required this.jobTypeName,
    required this.contractType,
    required this.description,
    required this.address,
    required this.location,
    required this.payment,
    this.photo,
    this.deadline,
    required this.customAnswers,
    required this.questions,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',

      jobTypeKey:
      json['jobTypeKey']?.toString() ?? '',

      jobTypeName:
      json['jobTypeName']?.toString() ?? '',

      contractType:
      json['contractType']?.toString() ?? '',

      description:
      json['description']?.toString() ?? '',

      address:
      json['address']?.toString() ?? '',

      location: Location.fromJson(
        json['location'] is Map<String, dynamic>
            ? json['location']
            : {},
      ),

      payment: Payment.fromJson(
        json['payment'] is Map<String, dynamic>
            ? json['payment']
            : {},
      ),

      photo: json['photo']?.toString(),

      deadline: json['deadline'] != null
          ? DateTime.tryParse(
        json['deadline'].toString(),
      )
          : null,

      customAnswers:
      _parseList(json['customAnswers']),

      questions:
      _parseQuestions(json['questions']),
    );
  }

  static List<dynamic> _parseList(dynamic value) {
    if (value is List) {
      return List<dynamic>.from(value);
    }

    if (value is Map<String, dynamic>) {
      return [value];
    }

    return [];
  }

  static List<OfferQuestion> _parseQuestions(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(
          (question) =>
          OfferQuestion.fromJson(question),
    )
        .toList();
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(
      Map<String, dynamic> json,
      ) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Payment {
  final num amount;
  final String currency;
  final String period;

  Payment({
    required this.amount,
    required this.currency,
    required this.period,
  });

  factory Payment.fromJson(
      Map<String, dynamic> json,
      ) {
    return Payment(
      amount: json['amount'] as num? ?? 0,
      currency:
      json['currency']?.toString() ?? '',
      period:
      json['period']?.toString() ?? '',
    );
  }
}

class OfferQuestion {
  final String id;
  final String label;
  final String type;
  final bool required;

  OfferQuestion({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
  });

  factory OfferQuestion.fromJson(
      Map<String, dynamic> json,
      ) {
    return OfferQuestion(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type:
      json['type']?.toString() ?? 'text',
      required:
      json['required'] == true,
    );
  }
}