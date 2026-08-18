import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/networks/api_client.dart';
import '../models/employer.dart';

/// Servicio del empleador (Persona 3).
/// Solo métodos que NO existen en offer_service ni contract_service.
class EmployerService {
  final ApiClient apiClient;

  EmployerService({required this.apiClient});

  /// POST /offers/{id}/deactivate
  Future<void> deactivateOffer(String id) async {
    final response = await apiClient.post('/offers/$id/deactivate');
    _check(response);
  }

  /// GET /offers/{id}/applications
  Future<List<Applicant>> getApplicants(String offerId) async {
    final response = await apiClient.get('/offers/$offerId/applications');
    _check(response);

    return _extractList(response)
        .whereType<Map<String, dynamic>>()
        .map(Applicant.fromJson)
        .toList();
  }

  /// PATCH /applications/{id} - calificar/descartar/finalista/ganador
  Future<void> updateApplication(
    String id, {
    String? status,
    int? rating,
    double? salary,
    String? currency,
    String? startDate,
    String? duration,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (rating != null) body['rating'] = rating;
    if (salary != null) body['salary'] = salary;
    if (currency != null) body['currency'] = currency;
    if (startDate != null) body['startDate'] = startDate;
    if (duration != null) body['duration'] = duration;

    final response = await apiClient.patch('/applications/$id', body: body);
    _check(response);
  }

  /// POST /payments - cobro simulado 1 USD
  Future<String> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    String? cardholder,
  }) async {
    final body = <String, dynamic>{
      'cardNumber': cardNumber,
      'cvv': cvv,
      'expMonth': expMonth,
      'expYear': expYear,
    };
    if (cardholder != null && cardholder.isNotEmpty) {
      body['cardholder'] = cardholder;
    }

    final response = await apiClient.post('/payments', body: body);
    _check(response);

    final data = _parseBody(response);
    final id = data is Map<String, dynamic>
        ? (data['data']?['id'] ?? data['id'] ?? data['paymentId'])
        : null;

    if (id == null) {
      throw Exception('No se recibió paymentId del servidor');
    }
    return id.toString();
  }

  /// POST /uploads - subir foto base64
  Future<String> uploadPhoto(String base64Image) async {
    final response = await apiClient.post(
      '/uploads',
      body: {'image': base64Image},
    );
    _check(response);

    final data = _parseBody(response);
    final url = data is Map<String, dynamic>
        ? (data['data']?['url'] ?? data['url'])
        : null;

    if (url == null) {
      throw Exception('No se recibió URL de la foto');
    }
    return url.toString();
  }

  // Helpers
  void _check(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Error API ${r.statusCode}: ${r.body}');
    }
  }

  dynamic _parseBody(http.Response r) {
    if (r.body.isEmpty) return null;
    try {
      return jsonDecode(r.body);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _extractList(http.Response r) {
    final d = _parseBody(r);
    if (d is List) return d;
    if (d is Map<String, dynamic>) {
      if (d['data'] is List) return d['data'];
      if (d['applications'] is List) return d['applications'];
    }
    return const [];
  }
}