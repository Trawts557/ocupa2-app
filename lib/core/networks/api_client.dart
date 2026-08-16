// lib/core/networks/api_client.dart
//
// Cliente HTTP temporal para Ocupa2.
// El JWT debe asignarse después del login:
//
// apiClient.jwt = token;

import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = 'https://ocupa2.ia3x.com/apix';

  String? jwt;

  ApiClient({this.jwt});

  // ============================================================
  // HEADERS
  // ============================================================

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (jwt != null && jwt!.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${jwt!.trim()}';
    }

    return headers;
  }

  // ============================================================
  // GET
  // ============================================================

  Future<dynamic> get(String path) async {
    final url = Uri.parse('$baseUrl$path');

    print('========================================');
    print('GET');
    print('URL: $url');
    print('JWT configurado: ${_hasJwt}');
    print('========================================');

    final response = await http.get(
      url,
      headers: _headers,
    );

    print('STATUS: ${response.statusCode}');
    print('RESPUESTA: ${response.body}');

    return _handle(response);
  }

  // ============================================================
  // POST
  // ============================================================

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$path');

    print('========================================');
    print('POST');
    print('URL: $url');
    print('JWT configurado: ${_hasJwt}');
    print('BODY: $body');
    print('========================================');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    print('STATUS: ${response.statusCode}');
    print('RESPUESTA: ${response.body}');

    return _handle(response);
  }

  // ============================================================
  // PATCH
  // ============================================================

  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$path');

    print('========================================');
    print('PATCH');
    print('URL: $url');
    print('JWT configurado: ${_hasJwt}');
    print('BODY: $body');
    print('========================================');

    final response = await http.patch(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    print('STATUS: ${response.statusCode}');
    print('RESPUESTA: ${response.body}');

    return _handle(response);
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<dynamic> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');

    print('========================================');
    print('DELETE');
    print('URL: $url');
    print('JWT configurado: ${_hasJwt}');
    print('========================================');

    final response = await http.delete(
      url,
      headers: _headers,
    );

    print('STATUS: ${response.statusCode}');
    print('RESPUESTA: ${response.body}');

    return _handle(response);
  }

  // ============================================================
  // JWT
  // ============================================================

  bool get _hasJwt {
    return jwt != null && jwt!.trim().isNotEmpty;
  }

  void setToken(String token) {
    jwt = token.trim();

    print('JWT configurado correctamente.');
  }

  void clearToken() {
    jwt = null;

    print('JWT eliminado.');
  }

  // ============================================================
  // MANEJO DE RESPUESTAS
  // ============================================================

  dynamic _handle(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return null;
      }

      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    }

    if (statusCode == 401) {
      throw Exception(
        'Error 401: No autorizado. '
        'El JWT falta, es inválido o expiró.',
      );
    }

    if (statusCode == 403) {
      throw Exception(
        'Error 403: No tienes permisos para realizar esta operación.',
      );
    }

    if (statusCode == 404) {
      throw Exception(
        'Error 404: Endpoint no encontrado.',
      );
    }

    if (statusCode >= 500) {
      throw Exception(
        'Error $statusCode: Problema en el servidor.\n'
        '${response.body}',
      );
    }

    throw Exception(
      'Error $statusCode: ${response.body}',
    );
  }
}