/// Estados de una aplicación que puede devolver el API.
/// Normaliza los distintos nombres que pueda usar el backend.
enum ApplicationStatus {
  review,
  discarded,
  finalist,
  winner,
  unknown;

  static ApplicationStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'review':
      case 'revision':
      case 'pending':
      case 'in_review':
      case 'en_revision':
        return review;
      case 'discarded':
      case 'descartado':
      case 'rejected':
        return discarded;
      case 'finalist':
      case 'finalista':
        return finalist;
      case 'winner':
      case 'ganador':
        return winner;
      default:
        return unknown;
    }
  }
}

/// Resumen de la oferta incluido dentro de la aplicación.
class ApplicationOffer {
  final String? id;
  final String? title;
  final String? jobType;
  final String? photoUrl;
  final String? description;

  /// Datos del empleador: el API solo debería devolverlos
  /// cuando el aplicante es el GANADOR (privacidad de la consigna).
  final String? employerName;
  final String? employerPhone;

  const ApplicationOffer({
    this.id,
    this.title,
    this.jobType,
    this.photoUrl,
    this.description,
    this.employerName,
    this.employerPhone,
  });

  factory ApplicationOffer.fromJson(Map<String, dynamic> json) {
    final employer =
        _firstMap(json, ['employer', 'publisher', 'owner', 'client', 'user']);

    return ApplicationOffer(
      id: _stringOrNull(json['id']) ?? _stringOrNull(json['_id']),
      title: _firstString(json, ['title', 'name', 'job_title']),
      jobType:
          _firstString(json, ['job_type', 'type', 'job_type_name', 'category']),
      photoUrl:
          _firstString(json, ['photo', 'photo_url', 'image', 'image_url', 'picture']),
      description: _firstString(json, ['description', 'detail', 'details']),
      employerName: employer == null
          ? null
          : _firstString(employer, ['name', 'full_name', 'fullname', 'nombre']),
      employerPhone: employer == null
          ? null
          : _firstString(employer, ['phone', 'telefono', 'tel', 'mobile']),
    );
  }
}

/// Una aplicación del usuario a una oferta.
class Application {
  final String? id;
  final String? status;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ApplicationOffer? offer;
  final Map<String, dynamic> raw;

  const Application({
    this.id,
    this.status,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.offer,
    this.raw = const {},
  });

  ApplicationStatus get statusEnum => ApplicationStatus.fromString(status);

  /// Solo el ganador puede ver los datos del empleador.
  bool get isWinner => statusEnum == ApplicationStatus.winner;

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: _stringOrNull(json['id']) ?? _stringOrNull(json['_id']),
      status: _firstString(json, ['status', 'state', 'estado']),
      comment: _firstString(json, ['comment', 'commentary', 'message']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      offer: _parseOffer(json),
      raw: json,
    );
  }

  static ApplicationOffer? _parseOffer(Map<String, dynamic> json) {
    final offerJson =
        _firstMap(json, ['offer', 'job', 'job_offer', 'oferta', 'joboffer']);
    if (offerJson != null) return ApplicationOffer.fromJson(offerJson);

    final flatTitle =
        _firstString(json, ['offer_title', 'job_title', 'offer_name']);
    if (flatTitle != null) {
      return ApplicationOffer.fromJson({'title': flatTitle});
    }
    return null;
  }
}

// ---------- Helpers de parseo ----------

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = _stringOrNull(json[key]);
    if (parsed != null && parsed.trim().isNotEmpty) return parsed;
  }
  return null;
}

Map<String, dynamic>? _firstMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}