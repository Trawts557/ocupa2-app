import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ocupa2_app/services/session_service.dart';

class ApiClient {
  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';
  final SessionService _sessionService = SessionService();
  
  Future<Map<String, String>> _headers() async {
    final token = await _sessionService.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(
    String endpoint, {
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.get(
      url,
      headers: await _headers(),
    );
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.post(
      url,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.put(
      url,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.patch(
      url,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.delete(
      url,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
  }
}