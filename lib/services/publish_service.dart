import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/models/job_type.dart';
import 'package:ocupa2_app/models/offer.dart';
import 'package:ocupa2_app/models/application.dart';

class PublishService {
  final ApiClient _api;
  PublishService(this._api);

  // GET /job-types
  Future<List<JobType>> getJobTypes() async {
    final data = await _api.get('/job-types');
    return (data as List).map((e) => JobType.fromJson(e)).toList();
  }

  // POST /uploads  (imagen en base64, según lo indique Swagger)
  Future<String> uploadImage(String base64Image) async {
    final data = await _api.post('/uploads', {
      'file': base64Image,
    });
    return data['url']; // ajustar al nombre real del campo devuelto
  }

  // POST /offers
  Future<Offer> publishOffer(Offer offer) async {
    final data = await _api.post('/offers', offer.toJson());
    return Offer.fromJson(data);
  }

  // GET /me/offers
  Future<List<Offer>> getMyOffers() async {
    final data = await _api.get('/me/offers');
    return (data as List).map((e) => Offer.fromJson(e)).toList();
  }

  // GET /offers/{id}/applications
  Future<List<Application>> getOfferApplications(String offerId) async {
    final data = await _api.get('/offers/$offerId/applications');
    return (data as List).map((e) => Application.fromJson(e)).toList();
  }

  // PATCH /applications/{id}  → calificar / descartar / finalista / ganador
  Future<Application> updateApplication(
    String applicationId, {
    double? rating,
    String? status, // 'descartado' | 'finalista' | 'ganador'
  }) async {
    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    if (status != null) body['status'] = status;
    final data = await _api.patch('/applications/$applicationId', body);
    return Application.fromJson(data);
  }

  // POST /offers/{id}/deactivate
  Future<void> deactivateOffer(String offerId) async {
    await _api.post('/offers/$offerId/deactivate', {});
  }
}