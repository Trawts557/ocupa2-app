import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
// NOTA: Si tu ApiClient está en otra carpeta, ajusta este import.
// Según tu guía, Persona 1 maneja 'core/', así que probablemente sea:
import '../core/networks/api_client.dart'; 
// Si te da error de URI, cámbialo a: import 'package:ocupa2_app/services/api_client.dart';

import '../models/experience.dart';

class ExperienceService {
  final ApiClient apiClient;

  ExperienceService({required this.apiClient});

  /// GET /me/experiences
  Future<List<Experience>> getMyExperiences() async {
    final response = await apiClient.get('/me/experiences');
    _checkSuccess(response);

    final jsonList = _extractList(response);
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(Experience.fromJson)
        .toList();
  }

  /// POST /me/experiences
  Future<Experience> createExperience({
    required String title,
    required String description,
    String? certificateUrl,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
    };

    // Solo agregamos los campos si no son nulos
    if (certificateUrl != null) body['certificate_url'] = certificateUrl;
    if (startDate != null) body['start_date'] = startDate.toIso8601String();
    if (endDate != null) body['end_date'] = endDate.toIso8601String();

    final response = await apiClient.post('/me/experiences', body: body);
    _checkSuccess(response);

    final map = _extractMap(response);
    return Experience.fromJson(map);
  }

  /// DELETE /me/experiences/{id}
  Future<void> deleteExperience(String experienceId) async {
    final response = await apiClient.delete('/me/experiences/$experienceId');
    _checkSuccess(response);
  }

  /// POST /uploads (Sube la imagen en Base64)
  Future<String> uploadCertificate(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await apiClient.post(
      '/uploads',
      body: {'image': base64Image},
    );
    
    _checkSuccess(response);
    final map = _extractMap(response);

    // Buscamos la URL en las posibles respuestas del API
    return map['url']?.toString() ?? 
           map['path']?.toString() ?? 
           map['file_url']?.toString() ?? '';
  }

  /// Flujo completo: Subir foto + Crear experiencia
  Future<Experience> createExperienceWithCertificate({
    required String title,
    required String description,
    File? certificateFile,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String? certificateUrl;

    if (certificateFile != null) {
      certificateUrl = await uploadCertificate(certificateFile);
    }

    return createExperience(
      title: title,
      description: description,
      certificateUrl: certificateUrl,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // --- UTILIDADES DE PARSEO Y MANEJO DE ERRORES ---

  void _checkSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Aquí puedes lanzar una excepción personalizada en el futuro
      throw Exception('Error API ${response.statusCode}: ${response.body}');
    }
  }

  dynamic _parseBody(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null; // Si el servidor no devolvió JSON válido
    }
  }

  List<dynamic> _extractList(http.Response response) {
    final data = _parseBody(response);
    if (data is List) return data;
    
    if (data is Map<String, dynamic>) {
      if (data['data'] is List) return data['data'];
      if (data['items'] is List) return data['items'];
      if (data['experiences'] is List) return data['experiences'];
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(http.Response response) {
    final data = _parseBody(response);
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) return data['data'];
      return data;
    }
    return const {};
  }
}