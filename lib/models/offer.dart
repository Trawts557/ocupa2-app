class Offer {
  final String id;
  final String jobTypeKey;
  final String jobTypeName;
  final String contractType;
  final String description;
  final String address;
  final Location location;
  final OfferPayment payment;
  final String? photo;
  final String? paymentId; // ID del pago de 1 USD, requerido para publicar
  final DateTime? deadline;
  final Map<String, dynamic> customAnswers;
  final List<OfferQuestion> questions;
  final bool active;

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
    this.paymentId,
    this.deadline,
    required this.customAnswers,
    required this.questions,
    this.active = true,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',
      jobTypeKey: json['jobTypeKey']?.toString() ?? '',
      jobTypeName: json['jobTypeName']?.toString() ?? '',
      contractType: json['contractType']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      location: Location.fromJson(
        json['location'] is Map<String, dynamic> ? json['location'] : {},
      ),
      payment: OfferPayment.fromJson(
        json['payment'] is Map<String, dynamic> ? json['payment'] : {},
      ),
      photo: json['photo']?.toString(),
      paymentId: json['paymentId']?.toString(),
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
      customAnswers: json['customAnswers'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['customAnswers'])
          : {},
      questions: _parseQuestions(json['questions']),
      active: json['active'] ?? true,
    );
  }

  // body exacto que espera POST /offers
  Map<String, dynamic> toJson() {
    return {
      'jobTypeKey': jobTypeKey,
      'contractType': contractType,
      'description': description,
      'address': address,
      'photo': photo,
      'paymentId': paymentId,
      'location': {'lat': location.lat, 'lng': location.lng},
      'payment': {'amount': payment.amount, 'currency': payment.currency},
      if (deadline != null)
        'deadline':
            '${deadline!.year.toString().padLeft(4, '0')}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}',
      'customAnswers': customAnswers,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  static List<OfferQuestion> _parseQuestions(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((q) => OfferQuestion.fromJson(q))
        .toList();
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
    );
  }
}

// Renombrada de "Payment" a "OfferPayment" para no chocar con
// el modelo Payment de la pasarela de cobro (models/payment.dart)
class OfferPayment {
  final num amount;
  final String currency;

  OfferPayment({required this.amount, required this.currency});

  factory OfferPayment.fromJson(Map<String, dynamic> json) {
    return OfferPayment(
      amount: json['amount'] as num? ?? 0,
      currency: json['currency']?.toString() ?? '',
    );
  }
}

class OfferQuestion {
  final String? id;
  final String label;
  final String type;
  final bool required;
  final List<String>? options;

  OfferQuestion({
    this.id,
    required this.label,
    required this.type,
    required this.required,
    this.options,
  });

  factory OfferQuestion.fromJson(Map<String, dynamic> json) {
    return OfferQuestion(
      id: json['id']?.toString(),
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      required: json['required'] == true,
      options: (json['options'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'type': type,
      'required': required,
      if (options != null) 'options': options,
    };
  }
}