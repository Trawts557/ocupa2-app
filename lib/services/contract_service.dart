import 'dart:convert';

import '../core/networks/api_client.dart';
import '../models/contract.dart';

class ContractService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Contract>> getMyContracts({String? status}) async {
    String endpoint = '/me/contracts';

    if (status != null && status.isNotEmpty) {
      endpoint += '?status=$status';
    }

    final response = await _apiClient.get(endpoint);

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = responseBody['data'];

      if (data is! List) {
        return [];
      }

      return data
          .map<Contract>(
            (json) => Contract.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Error al obtener los contratos (${response.statusCode})',
    );
  }

  Future<Map<String, dynamic>> getContractById(String id) async {
    final response = await _apiClient.get('/contracts/$id');

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseBody['data'];
    }

    if (response.statusCode == 403) {
      throw Exception('No eres parte de este contrato');
    }

    if (response.statusCode == 404) {
      throw Exception('Contrato no encontrado');
    }

    throw Exception(
      'Error al obtener el contrato (${response.statusCode})',
    );
  }

  Future<void> acceptContract(String id) async {
    final response = await _apiClient.post(
      '/contracts/$id/accept',
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 409) {
      throw Exception(
        'El contrato no está pendiente o no tiene términos definidos',
      );
    }

    throw Exception(
      'No se pudo aceptar el contrato (${response.statusCode})',
    );
  }

  Future<void> rejectContract(String id) async {
    final response = await _apiClient.post(
      '/contracts/$id/reject',
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      'No se pudo rechazar el contrato (${response.statusCode})',
    );
  }

  Future<void> setTerms({
    required String id,
    required double salary,
    required String currency,
    required String startDate,
    required String duration,
  }) async {
    final response = await _apiClient.put(
      '/contracts/$id/terms',
      body: {
        'salary': salary,
        'currency': currency,
        'startDate': startDate,
        'duration': duration,
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Solo el contratante puede fijar los términos',
      );
    }

    throw Exception(
      'No se pudieron actualizar los términos '
      '(${response.statusCode})',
    );
  }

  Future<void> addComment({
    required String id,
    required String body,
  }) async {
    final response = await _apiClient.post(
      '/contracts/$id/comments',
      body: {
        'body': body,
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 409) {
      throw Exception(
        'Solo se puede comentar en un contrato activo',
      );
    }

    throw Exception(
      'No se pudo agregar el comentario (${response.statusCode})',
    );
  }

  Future<void> addPhoto({
    required String id,
    required String photo,
    required String description,
  }) async {
    final response = await _apiClient.post(
      '/contracts/$id/photos',
      body: {
        'photo': photo,
        'description': description,
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 422) {
      throw Exception(
        'La imagen no es válida o tiene un formato no permitido',
      );
    }

    throw Exception(
      'No se pudo agregar la foto (${response.statusCode})',
    );
  }

  Future<void> cancelContract({
    required String id,
    required String justification,
  }) async {
    final response = await _apiClient.post(
      '/contracts/$id/cancel',
      body: {
        'justification': justification,
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 409) {
      throw Exception(
        'Solo se puede cancelar un contrato activo',
      );
    }

    throw Exception(
      'No se pudo cancelar el contrato (${response.statusCode})',
    );
  }
}