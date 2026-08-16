/// Video de YouTube curado por el admin, devuelto por GET /videos.
class Video {
  final String? id;
  final String? title;
  final String? description;
  final String? url;
  final String? thumbnailUrl;
  final String? youtubeId;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  const Video({
    this.id,
    this.title,
    this.description,
    this.url,
    this.thumbnailUrl,
    this.youtubeId,
    this.createdAt,
    this.raw = const {},
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    final rawUrl = _firstString(json, [
      'url',
      'video_url',
      'videoUrl',
      'link',
      'youtube_url',
      'youtubeUrl',
      'href',
    ]);
    final ytId =
        _firstString(json, ['youtube_id', 'youtubeId', 'video_id', 'videoId']) ??
            _extractYoutubeId(rawUrl);

    return Video(
      id: _stringOrNull(json['id']) ?? _stringOrNull(json['_id']),
      title: _firstString(json, ['title', 'name']),
      description: _firstString(json, ['description', 'detail', 'details']),
      url: rawUrl,
      thumbnailUrl: _firstString(json, [
            'thumbnail',
            'thumbnail_url',
            'thumbnailUrl',
            'image',
            'image_url',
            'photo',
          ]) ??
          (ytId != null
              ? 'https://img.youtube.com/vi/$ytId/hqdefault.jpg'
              : null),
      youtubeId: ytId,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      raw: json,
    );
  }
}

/// Extrae el ID de YouTube desde los formatos de URL más comunes.
String? _extractYoutubeId(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final clean = url.trim();

  // Si ya es solo el ID (11 caracteres).
  if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(clean)) return clean;

  final uri = Uri.tryParse(clean);
  if (uri == null) return null;

  if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.first;
  }

  if (uri.host.contains('youtube.com')) {
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;

    final seg = uri.pathSegments;
    for (final marker in ['embed', 'shorts', 'live']) {
      final idx = seg.indexOf(marker);
      if (idx != -1 && seg.length > idx + 1) return seg[idx + 1];
    }
  }

  return null;
}

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