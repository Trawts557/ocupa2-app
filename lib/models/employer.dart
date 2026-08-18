/// Aplicante a una oferta (para que el empleador los gestione).
class Applicant {
  final String? id;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final String? comment;
  final String? status;
  final DateTime? createdAt;

  const Applicant({
    this.id,
    this.name,
    this.phone,
    this.photoUrl,
    this.comment,
    this.status,
    this.createdAt,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    final person = _firstMap(json, ['user', 'applicant', 'profile', 'owner']);
    final first = _str(person?['firstName']) ?? _str(person?['first_name']);
    final last = _str(person?['lastName']) ?? _str(person?['last_name']);
    final full = [first, last]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ');

    return Applicant(
      id: _str(json['id']) ?? _str(json['_id']),
      name: _str(person?['nombre']) ??
          _str(person?['name']) ??
          (full.isNotEmpty ? full : null),
      phone: _str(person?['phone']) ?? _str(person?['telefono']),
      photoUrl: _str(person?['photoUrl']) ?? _str(person?['photo']),
      comment: _str(json['comment']) ?? _str(json['message']),
      status: _str(json['status']) ?? _str(json['state']),
      createdAt: _date(json['createdAt'] ?? json['created_at']),
    );
  }
}

// Helpers
String? _str(dynamic v) => v is String ? v : v?.toString();

DateTime? _date(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) return DateTime.tryParse(v);
  return null;
}

Map<String, dynamic>? _firstMap(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v is Map<String, dynamic>) return v;
  }
  return null;
}