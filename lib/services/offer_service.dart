import 'dart:convert';

import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/models/offer.dart';

class OfferService {
  final ApiClient _apiClient = ApiClient();

  /// Obtener todas las ofertas publicadas
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    String endpoint = '/offers';

    final queryParameters = <String, String>{};

    if (jobTypeKey != null && jobTypeKey.isNotEmpty) {
      queryParameters['jobTypeKey'] = jobTypeKey;
    }

    if (contractType != null && contractType.isNotEmpty) {
      queryParameters['contractType'] = contractType;
    }

    if (queryParameters.isNotEmpty) {
      endpoint +=
      '?${Uri(queryParameters: queryParameters).query}';
    }

    final response = await _apiClient.get(endpoint);

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener las ofertas: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> json =
    jsonDecode(response.body);

    if (json['ok'] != true) {
      throw Exception(
        json['error']?.toString() ??
            'No se pudieron obtener las ofertas',
      );
    }

    return _parseOffers(json['data']);
  }

  /// Obtener el detalle de una oferta
  Future<Offer> getOfferById(String id) async {
    final response =
    await _apiClient.get('/offers/$id');

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener la oferta: '
            '${response.statusCode}',
      );
    }

    final Map<String, dynamic> json =
    jsonDecode(response.body);

    if (json['ok'] != true) {
      throw Exception(
        json['error']?.toString() ??
            'No se pudo obtener la oferta',
      );
    }

    final data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta de la oferta no tiene '
            'un formato válido.',
      );
    }

    return Offer.fromJson(data);
  }

  /// Postularse a una oferta
  Future<void> applyToOffer({
    required String offerId,
    String? comment,
    required List<Map<String, String>> answers,
  }) async {
    final body = {
      'comment': comment ?? '',
      'answers': answers,
    };

    final response = await _apiClient.post(
      '/offers/$offerId/apply',
      body: body,
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic>? json =
      _tryDecode(response.body);

      throw Exception(
        json?['error']?.toString() ??
            'No se pudo realizar la postulación '
                '(${response.statusCode})',
      );
    }
  }

  /// Obtener mis ofertas publicadas
  Future<List<Offer>> getMyOffers() async {
    final response =
    await _apiClient.get('/me/offers');

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener mis ofertas: '
            '${response.statusCode}',
      );
    }

    final Map<String, dynamic> json =
    jsonDecode(response.body);

    if (json['ok'] != true) {
      throw Exception(
        json['error']?.toString() ??
            'No se pudieron obtener mis ofertas',
      );
    }

    return _parseOffers(json['data']);
  }

  /// Obtener mis postulaciones
  ///
  /// La API devuelve:
  ///
  /// data: [
  ///   {
  ///     "id": "...",
  ///     "offerId": "...",
  ///     "status": "applied",
  ///     "comment": "...",
  ///     "answers": [],
  ///     "offer": {
  ///       "id": "...",
  ///       "jobTypeName": "...",
  ///       "description": "...",
  ///       "address": "...",
  ///       ...
  ///     }
  ///   }
  /// ]
  ///
  /// Por eso aquí extraemos item['offer'].
  Future<List<Offer>> getMyApplications() async {
    final response =
    await _apiClient.get('/me/applications');

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener mis postulaciones: '
            '${response.statusCode}',
      );
    }

    final Map<String, dynamic> json =
    jsonDecode(response.body);

    if (json['ok'] != true) {
      throw Exception(
        json['error']?.toString() ??
            'No se pudieron obtener mis postulaciones',
      );
    }

    final data = json['data'];

    if (data is! List) {
      return [];
    }

    final List<Offer> applications = [];

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final offerData = item['offer'];

        if (offerData is Map<String, dynamic>) {
          applications.add(
            Offer.fromJson(offerData),
          );
        }
      }
    }

    return applications;
  }

  /// Crear una oferta
  Future<void> createOffer({
    required String jobTypeKey,
    required String contractType,
    required String description,
    required String address,
    required double lat,
    required double lng,
    required double amount,
    required String currency,
    String? paymentId,
    String? photo,
    DateTime? deadline,
  }) async {
    final body = {
      'jobTypeKey': jobTypeKey,
      'contractType': contractType,
      'description': description,
      'address': address,
      'photo': photo,
      'location': {
        'lat': lat,
        'lng': lng,
      },
      'payment': {
        'amount': amount,
        'currency': currency,
      },
      'deadline': deadline != null
          ? '${deadline.year.toString().padLeft(4, '0')}-'
          '${deadline.month.toString().padLeft(2, '0')}-'
          '${deadline.day.toString().padLeft(2, '0')}'
          : null,
    };

    if (paymentId != null && paymentId.isNotEmpty) {
      body['paymentId'] = paymentId;
    }

    final response = await _apiClient.post(
      '/offers',
      body: body,
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic>? json =
      _tryDecode(response.body);

      throw Exception(
        json?['error']?.toString() ??
            'No se pudo publicar la oferta '
                '(${response.statusCode})',
      );
    }
  }

  /// Convierte la respuesta de la API
  /// en una lista de ofertas.
  List<Offer> _parseOffers(dynamic data) {
    List<dynamic> items = [];

    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic>) {
      if (data['offers'] is List) {
        items = data['offers'] as List;
      } else if (data['items'] is List) {
        items = data['items'] as List;
      } else if (data['results'] is List) {
        items = data['results'] as List;
      } else if (data['data'] is List) {
        items = data['data'] as List;
      }
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => Offer.fromJson(item),
    )
        .toList();
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