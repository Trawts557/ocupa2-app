class Experience {
  final String? id;
  final String? title;
  final String? description;
  final String? certificateUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic> raw;

  const Experience({
    this.id,
    this.title,
    this.description,
    this.certificateUrl,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.raw = const {},
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: _stringOrNull(json['id']) ?? _stringOrNull(json['_id']),
      title: _firstString(
        json,
        ['title', 'name', 'position', 'role', 'experience_title'],
      ),
      description: _firstString(
        json,
        ['description', 'detail', 'details', 'comment'],
      ),
      certificateUrl: _firstString(
        json,
        [
          'certificate_url',
          'certificate',
          'certificate_image',
          'certificate_image_url',
          'image_url',
          'image',
          'file_url',
          'url',
        ],
      ),
      startDate: _parseDate(
        json['start_date'] ?? json['startDate'] ?? json['inicio'],
      ),
      endDate: _parseDate(
        json['end_date'] ?? json['endDate'] ?? json['fin'],
      ),
      createdAt: _parseDate(
        json['created_at'] ?? json['createdAt'],
      ),
      updatedAt: _parseDate(
        json['updated_at'] ?? json['updatedAt'],
      ),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (certificateUrl != null) 'certificate_url': certificateUrl,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
    };
  }

  Experience copyWith({
    String? id,
    String? title,
    String? description,
    String? certificateUrl,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? raw,
  }) {
    return Experience(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      raw: raw ?? this.raw,
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static String? _firstString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      final parsed = _stringOrNull(value);

      if (parsed != null && parsed.trim().isNotEmpty) {
        return parsed;
      }
    }

    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}