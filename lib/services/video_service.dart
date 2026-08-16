import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/networks/api_client.dart';
import '../models/video.dart';

/// Servicio de videos (Persona 4). Endpoint: GET /videos
class VideoService {
  final ApiClient apiClient;

  VideoService({required this.apiClient});

  /// GET /videos
  Future<List<Video>> getVideos() async {
    final response = await apiClient.get('/videos');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error API ${response.statusCode}: ${response.body}');
    }

    return _extractList(response)
        .whereType<Map<String, dynamic>>()
        .map(Video.fromJson)
        .toList();
  }

  dynamic _parseBody(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _extractList(http.Response response) {
    final data = _parseBody(response);
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) return data['data'];
      if (data['items'] is List) return data['items'];
      if (data['videos'] is List) return data['videos'];
    }
    return const [];
  }
}