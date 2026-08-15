/// Noticia de empleo devuelta por GET /news.
class News {
  final String? id;
  final String? title;
  final String? summary;
  final String? content;
  final String? imageUrl;
  final String? source;
  final String? linkUrl;
  final DateTime? publishedAt;
  final Map<String, dynamic> raw;

  const News({
    this.id,
    this.title,
    this.summary,
    this.content,
    this.imageUrl,
    this.source,
    this.linkUrl,
    this.publishedAt,
    this.raw = const {},
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: _stringOrNull(json['id']) ?? _stringOrNull(json['_id']),
      title: _firstString(json, ['title', 'headline', 'name']),
      summary: _firstString(json, ['summary', 'excerpt', 'intro', 'description']),
      content: _firstString(json, ['content', 'body', 'text', 'article']),
      imageUrl: _firstString(json, [
        'image',
        'image_url',
        'imageUrl',
        'photo',
        'photo_url',
        'thumbnail',
        'img',
      ]),
      source: _firstString(json, ['source', 'author', 'site', 'feed']),
      linkUrl: _firstString(json, ['url', 'link', 'link_url', 'href']),
      publishedAt: _parseDate(
        json['published_at'] ??
            json['publishedAt'] ??
            json['date'] ??
            json['created_at'],
      ),
      raw: json,
    );
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

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}