/// Autor de un tema o comentario del foro.
class ForumAuthor {
  final String? id;
  final String? nombre;

  const ForumAuthor({this.id, this.nombre});

  factory ForumAuthor.fromJson(Map<String, dynamic> json) {
    return ForumAuthor(
      id: _str(json['id']),
      nombre: _str(json['nombre']) ?? _str(json['name']),
    );
  }
}

/// Comentario dentro de un tema.
class ForumComment {
  final String? id;
  final String? body;
  final ForumAuthor? author;
  final DateTime? createdAt;

  const ForumComment({this.id, this.body, this.author, this.createdAt});

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: _str(json['id']),
      body: _str(json['body']) ?? _str(json['content']),
      author: json['author'] is Map<String, dynamic>
          ? ForumAuthor.fromJson(json['author'])
          : null,
      createdAt: _date(json['createdAt'] ?? json['created_at']),
    );
  }
}

/// Tema del foro. En el detalle incluye la lista de [comments].
class ForumTopic {
  final String? id;
  final String? title;
  final String? description;
  final ForumAuthor? author;
  final int? commentsCount;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;
  final List<ForumComment> comments;

  const ForumTopic({
    this.id,
    this.title,
    this.description,
    this.author,
    this.commentsCount,
    this.createdAt,
    this.lastActivityAt,
    this.comments = const [],
  });

  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    final commentsRaw = json['comments'];
    return ForumTopic(
      id: _str(json['id']),
      title: _str(json['title']),
      description: _str(json['description']),
      author: json['author'] is Map<String, dynamic>
          ? ForumAuthor.fromJson(json['author'])
          : null,
      commentsCount: json['commentsCount'] is int
          ? json['commentsCount']
          : int.tryParse('${json['commentsCount'] ?? ''}'),
      createdAt: _date(json['createdAt'] ?? json['created_at']),
      lastActivityAt: _date(json['lastActivityAt'] ?? json['last_activity_at']),
      comments: commentsRaw is List
          ? commentsRaw
              .whereType<Map<String, dynamic>>()
              .map(ForumComment.fromJson)
              .toList()
          : const [],
    );
  }
}

String? _str(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}