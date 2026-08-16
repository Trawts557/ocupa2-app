class JobType {
  final String id;
  final String name;
  final List<JobTypeField> customFields;

  JobType({
    required this.id,
    required this.name,
    required this.customFields,
  });

  factory JobType.fromJson(Map<String, dynamic> json) {
    return JobType(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      customFields: (json['fields'] is List)
          ? (json['fields'] as List)
              .whereType<Map>()
              .map(
                (field) => JobTypeField.fromJson(
                  Map<String, dynamic>.from(field),
                ),
              )
              .toList()
          : [],
    );
  }
}

class JobTypeField {
  final String key;
  final String label;
  final String type;
  final List<String>? options;

  JobTypeField({
    required this.key,
    required this.label,
    required this.type,
    this.options,
  });

  factory JobTypeField.fromJson(Map<String, dynamic> json) {
    return JobTypeField(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      options: json['options'] is List
          ? (json['options'] as List)
              .map((option) => option.toString())
              .toList()
          : null,
    );
  }
}