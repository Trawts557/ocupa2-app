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
    final data = await _api.get('/job-types');

    print('RESPUESTA /job-types: $data');
    print('TIPO /job-types: ${data.runtimeType}');

    // Caso 1:
    // [
    //   { "id": "...", "name": "...", "fields": [] }
    // ]
    if (data is List) {
      return data
          .map(
            (item) => JobType.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    // Caso 2:
    // {
    //   "ok": true,
    //   "data": [
    //      { "id": "...", "name": "...", "fields": [] }
    //   ]
    // }
    if (data is Map) {
      final response = Map<String, dynamic>.from(data);

      final innerData = response['data'];

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
      'Formato inesperado en GET /job-types: $data',
    );
  }

  // ============================================================
  // POST /uploads
  // ============================================================
  Future<String> uploadImage(String base64Image) async {
    final data = await _api.post('/uploads', {
      'file': base64Image,
    });

    print('RESPUESTA /uploads: $data');

    if (data is Map) {
      final response = Map<String, dynamic>.from(data);

      // Caso:
      // { "url": "..." }
      if (response['url'] != null) {
        return response['url'].toString();
      }

      // Caso:
      // { "data": { "url": "..." } }
      if (response['data'] is Map) {
        final innerData = Map<String, dynamic>.from(
          response['data'],
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
    final data = await _api.post(
      '/offers',
      offer.toJson(),
    );

    print('RESPUESTA /offers: $data');

    if (data is Map) {
      final response = Map<String, dynamic>.from(data);

      // Caso:
      // { datos directamente de la oferta }
      if (response['id'] != null) {
        return Offer.fromJson(response);
      }

      // Caso:
      // { "data": { datos de la oferta } }
      if (response['data'] is Map) {
        return Offer.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
    }

    throw Exception(
      'Formato inesperado al publicar la oferta: $data',
    );
  }

  // ============================================================
  // GET /me/offers
  // ============================================================
  Future<List<Offer>> getMyOffers() async {
    final data = await _api.get('/me/offers');

    print('RESPUESTA /me/offers: $data');

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
      final response = Map<String, dynamic>.from(data);
      final innerData = response['data'];

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
      'Formato inesperado en GET /me/offers: $data',
    );
  }

  // ============================================================
  // GET /offers/{id}/applications
  // ============================================================
  Future<List<Application>> getOfferApplications(
    String offerId,
  ) async {
    final data = await _api.get(
      '/offers/$offerId/applications',
    );

    print(
      'RESPUESTA /offers/$offerId/applications: $data',
    );

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
      final response = Map<String, dynamic>.from(data);
      final innerData = response['data'];

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
      'Formato inesperado al obtener aplicaciones: $data',
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

    final data = await _api.patch(
      '/applications/$applicationId',
      body,
    );

    print(
      'RESPUESTA PATCH /applications/$applicationId: $data',
    );

    if (data is Map) {
      final response = Map<String, dynamic>.from(data);

      if (response['id'] != null) {
        return Application.fromJson(response);
      }

      if (response['data'] is Map) {
        return Application.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
    }

    throw Exception(
      'Formato inesperado al actualizar aplicación: $data',
    );
  }

  // ============================================================
  // POST /offers/{id}/deactivate
  // ============================================================
  Future<void> deactivateOffer(String offerId) async {
    await _api.post(
      '/offers/$offerId/deactivate',
      {},
    );
  }
}