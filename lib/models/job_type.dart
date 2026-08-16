class JobType {
  final String id;
  final String name;
  final List<JobTypeField> customFields;

  JobType({required this.id, required this.name, required this.customFields});

  factory JobType.fromJson(Map<String, dynamic> json) {
    return JobType(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      customFields: (json['fields'] as List? ?? [])
          .map((f) => JobTypeField.fromJson(f))
          .toList(),
    );
  }
}

class JobTypeField {
  final String key;
  final String label;
  final String type; // text | date | select | check
  final List<String>? options; // solo si type == select

  JobTypeField({
    required this.key,
    required this.label,
    required this.type,
    this.options,
  });

  factory JobTypeField.fromJson(Map<String, dynamic> json) {
    return JobTypeField(
      key: json['key'],
      label: json['label'],
      type: json['type'],
      options: (json['options'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}