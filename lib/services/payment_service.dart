import 'dart:convert';

import 'package:ocupa2_app/core/networks/api_client.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  /// Realizar un pago y obtener el paymentId
  Future<String> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    required String cardholder,
  }) async {
    final body = {
      'cardNumber': cardNumber,
      'cvv': cvv,
      'expMonth': expMonth,
      'expYear': expYear,
      'cardholder': cardholder,
    };

    final response = await _apiClient.post(
      '/payments',
      body: body,
    );

    final Map<String, dynamic>? json =
    _tryDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(
        json?['error']?.toString() ??
            'No se pudo realizar el pago '
                '(${response.statusCode})',
      );
    }

    if (json == null) {
      throw Exception(
        'Respuesta inválida del servidor.',
      );
    }

    final data = json['data'];

    if (data is Map<String, dynamic>) {
      final paymentId = data['id']?.toString();

      if (paymentId != null && paymentId.isNotEmpty) {
        return paymentId;
      }
    }

    final paymentId = json['id']?.toString();

    if (paymentId != null && paymentId.isNotEmpty) {
      return paymentId;
    }

    throw Exception(
      'El pago fue aprobado, pero no se recibió el paymentId.',
    );
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