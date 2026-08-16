import 'dart:convert';

import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/models/job_type.dart';
import 'package:ocupa2_app/models/offer.dart';
import 'package:ocupa2_app/models/application.dart';

class PublishService {
  final ApiClient _api;

  PublishService(this._api);

  // ============================================================
  // GET /job-types
  // ============================================================
  Future<List<JobType>> getJobTypes() async {
    final response = await _api.get('/job-types');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al obtener tipos de empleo '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is List) {
      return data
          .map(
            (item) => JobType.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    if (data is Map) {
      final responseData = Map<String, dynamic>.from(data);

      final innerData = responseData['data'];

      if (innerData is List) {
        return innerData
            .map(
              (item) => JobType.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    }

    throw Exception(
      'Formato inesperado en GET /job-types',
    );
  }

  // ============================================================
  // POST /uploads
  // ============================================================
  Future<String> uploadImage(String base64Image) async {
    final response = await _api.post(
      '/uploads',
      body: {
        'file': base64Image,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al subir la imagen '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is Map) {
      final responseData = Map<String, dynamic>.from(data);

      if (responseData['url'] != null) {
        return responseData['url'].toString();
      }

      if (responseData['data'] is Map) {
        final innerData = Map<String, dynamic>.from(
          responseData['data'],
        );

        if (innerData['url'] != null) {
          return innerData['url'].toString();
        }
      }
    }

    throw Exception(
      'No se encontró la URL de la imagen en la respuesta de /uploads',
    );
  }

  // ============================================================
  // POST /offers
  // ============================================================
  Future<Offer> publishOffer(Offer offer) async {
    final response = await _api.post(
      '/offers',
      body: offer.toJson(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al publicar la oferta '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is Map) {
      final responseData = Map<String, dynamic>.from(data);

      if (responseData['id'] != null) {
        return Offer.fromJson(responseData);
      }

      if (responseData['data'] is Map) {
        return Offer.fromJson(
          Map<String, dynamic>.from(responseData['data']),
        );
      }
    }

    throw Exception(
      'Formato inesperado al publicar la oferta',
    );
  }

  // ============================================================
  // GET /me/offers
  // ============================================================
  Future<List<Offer>> getMyOffers() async {
    final response = await _api.get('/me/offers');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al obtener mis ofertas '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is List) {
      return data
          .map(
            (item) => Offer.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    if (data is Map) {
      final responseData = Map<String, dynamic>.from(data);
      final innerData = responseData['data'];

      if (innerData is List) {
        return innerData
            .map(
              (item) => Offer.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    }

    throw Exception(
      'Formato inesperado en GET /me/offers',
    );
  }

  // ============================================================
  // GET /offers/{id}/applications
  // ============================================================
  Future<List<Application>> getOfferApplications(
    String offerId,
  ) async {
    final response = await _api.get(
      '/offers/$offerId/applications',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al obtener las aplicaciones '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is List) {
      return data
          .map(
            (item) => Application.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    if (data is Map) {
      final responseData = Map<String, dynamic>.from(data);
      final innerData = responseData['data'];

      if (innerData is List) {
        return innerData
            .map(
              (item) => Application.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    }

    throw Exception(
      'Formato inesperado al obtener aplicaciones',
    );
  }

  // ============================================================
  // PATCH /applications/{id}
  // ============================================================
  Future<Application> updateApplication(
    String applicationId, {
    double? rating,
    String? status,
  }) async {
    final body = <String, dynamic>{};

    if (rating != null) {
      body['rating'] = rating;
    }

    if (status != null) {
      body['status'] = status;
    }

    final response = await _api.patch(
      '/applications/$applicationId',
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al actualizar la aplicación '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is Map) {
      final responseData = Map<String, dynamic>.from(data);

      if (responseData['id'] != null) {
        return Application.fromJson(responseData);
      }

      if (responseData['data'] is Map) {
        return Application.fromJson(
          Map<String, dynamic>.from(responseData['data']),
        );
      }
    }

    throw Exception(
      'Formato inesperado al actualizar aplicación',
    );
  }

  // ============================================================
  // POST /offers/{id}/deactivate
  // ============================================================
  Future<void> deactivateOffer(String offerId) async {
    final response = await _api.post(
      '/offers/$offerId/deactivate',
      body: {},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo desactivar la oferta '
        '(${response.statusCode}): ${response.body}',
      );
    }
  }
}