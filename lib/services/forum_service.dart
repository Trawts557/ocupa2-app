import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/networks/api_client.dart';
import '../models/forum.dart';

/// Servicio del foro (endpoints reales del openapi.yaml).
class ForumService {
  final ApiClient apiClient;

  ForumService({required this.apiClient});

  /// GET /forum/topics
  Future<List<ForumTopic>> getTopics() async {
    final response = await apiClient.get('/forum/topics');
    _check(response);

    return _extractList(response)
        .whereType<Map<String, dynamic>>()
        .map(ForumTopic.fromJson)
        .toList();
  }

  /// GET /forum/topics/{id}
  Future<ForumTopic> getTopic(String id) async {
    final response = await apiClient.get('/forum/topics/$id');
    _check(response);

    final data = _extractObject(response);
    return ForumTopic.fromJson(data);
  }

  /// POST /forum/topics  (body: {title, description})
  Future<void> createTopic({
    required String title,
    required String description,
  }) async {
    final response = await apiClient.post(
      '/forum/topics',
      body: {'title': title, 'description': description},
    );
    _check(response);
  }

  /// POST /forum/topics/{id}/comments  (body: {body})
  Future<void> addComment({
    required String topicId,
    required String body,
  }) async {
    final response = await apiClient.post(
      '/forum/topics/$topicId/comments',
      body: {'body': body},
    );
    _check(response);
  }

  void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error API ${response.statusCode}: ${response.body}');
    }
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
      if (data['topics'] is List) return data['topics'];
    }
    return const [];
  }

  Map<String, dynamic> _extractObject(http.Response response) {
    final data = _parseBody(response);
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) return data['data'];
      return data;
    }
    return const {};
  }
}