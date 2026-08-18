import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/networks/api_client.dart';
import '../models/news.dart';

/// Servicio de noticias (Persona 4). Endpoint: GET /news
class NewsService {
  final ApiClient apiClient;

  NewsService({required this.apiClient});

  /// GET /news
  Future<List<News>> getNews() async {
    final response = await apiClient.get('/news');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error API ${response.statusCode}: ${response.body}');
    }

    return _extractList(response)
        .whereType<Map<String, dynamic>>()
        .map(News.fromJson)
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
      if (data['news'] is List) return data['news'];
    }
    return const [];
  }
}