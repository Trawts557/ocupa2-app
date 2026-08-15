import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/networks/api_client.dart';
import '../models/application.dart';

/// Servicio de seguimiento de aplicaciones (Persona 4).
/// Endpoint: GET /me/applications
class ApplicationService {
  final ApiClient apiClient;

  ApplicationService({required this.apiClient});

  /// GET /me/applications
  Future<List<Application>> getMyApplications() async {
    final response = await apiClient.get('/me/applications');
    _checkSuccess(response);

    return _extractList(response)
        .whereType<Map<String, dynamic>>()
        .map(Application.fromJson)
        .toList();
  }

  void _checkSuccess(http.Response response) {
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
      if (data['applications'] is List) return data['applications'];
    }
    return const [];
  }
}