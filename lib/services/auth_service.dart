import 'dart:convert';

import '../core/networks/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  
  Future<void> changePassword({
    required String password,
  }) async {
    final response = await _apiClient.put(
      '/me/password',
      body: {'password': password},
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      'No se pudo cambiar la contraseña (${response.statusCode})',
    );
  }

  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      body: {'email': email, 'referralMatricula': referralMatricula},
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      'No se pudo recuperar la contraseña (${response.statusCode})',
    );
  }

  Future<Map<String, dynamic>> completeProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required String birthDate,
  }) async {
    final response = await _apiClient.put(
      '/me/profile',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'cedula': cedula,
        'gender': gender,
        'birthDate': birthDate,
      },
    );

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    }

    if (response.statusCode == 422) {
      final message =
          responseBody['message'] ??
          responseBody['error'] ??
          'Los datos del perfil no son válidos';

      throw Exception(message);
    }

    throw Exception('Error al completar el perfil (${response.statusCode})');
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'referralMatricula': referralMatricula,
      },
    );

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return responseBody;
    }

    if (response.statusCode == 409) {
      throw Exception('El correo ya está registrado');
    }

    if (response.statusCode == 422) {
      final message =
          responseBody['message'] ??
          responseBody['error'] ??
          'Los datos enviados no son válidos';

      throw Exception(message);
    }

    throw Exception('Error al crear la cuenta (${response.statusCode})');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    }

    if (response.statusCode == 401) {
      throw Exception('Correo o contraseña incorrectos');
    }

    throw Exception('Error al iniciar sesión (${response.statusCode})');
  }
}
