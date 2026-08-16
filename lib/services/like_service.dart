import 'dart:convert';

import '../core/networks/api_client.dart';

class LikeService {
  final ApiClient _apiClient = ApiClient();

  /// Dar like a una oferta
  Future<void> likeOffer(String offerId) async {
    final response = await _apiClient.post(
      '/offers/$offerId/like',
      body: {},
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      final error = _tryDecode(response.body);

      throw Exception(
        error?['error']?.toString() ??
            'No se pudo dar like a la oferta '
                '(${response.statusCode})',
      );
    }
  }

  /// Quitar like de una oferta
  Future<void> unlikeOffer(String offerId) async {
    final response = await _apiClient.delete(
      '/offers/$offerId/like',
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      final error = _tryDecode(response.body);

      throw Exception(
        error?['error']?.toString() ??
            'No se pudo quitar el like '
                '(${response.statusCode})',
      );
    }
  }

  /// Obtener mis likes
  Future<List<String>> getMyLikes() async {
    final response = await _apiClient.get('/me/likes');

    if (response.statusCode != 200) {
      final error = _tryDecode(response.body);

      throw Exception(
        error?['error']?.toString() ??
            'No se pudieron obtener los likes '
                '(${response.statusCode})',
      );
    }

    final json = _tryDecode(response.body);

    if (json == null) {
      throw Exception(
        'Respuesta inválida del servidor',
      );
    }

    final data = json['data'];

    if (data is! List) {
      return [];
    }

    return data.map<String>((item) {
      if (item is String) {
        return item;
      }

      if (item is Map<String, dynamic>) {
        return item['offerId']?.toString() ??
            item['id']?.toString() ??
            '';
      }

      return '';
    }).where((id) => id.isNotEmpty).toList();
  }

  Map<String, dynamic>? _tryDecode(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}