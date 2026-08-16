import 'dart:convert';

import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/models/payment.dart';

class PaymentService {
  final ApiClient _api;

  PaymentService(this._api);

  // ============================================================
  // POST /payments
  // Cobro de 1 USD para publicar una oferta
  // ============================================================
  Future<Payment> payForOffer({
    required String offerId,
    required String cardholderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    final response = await _api.post(
      '/payments',
      body: {
        'offer_id': offerId,
        'amount': 1.00,
        'cardholder_name': cardholderName,
        'card_number': cardNumber,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cvv': cvv,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        // Caso:
        // {
        //   "id": "...",
        //   ...
        // }
        if (decoded['id'] != null) {
          return Payment.fromJson(decoded);
        }

        // Caso:
        // {
        //   "data": {
        //     "id": "...",
        //     ...
        //   }
        // }
        if (decoded['data'] is Map) {
          return Payment.fromJson(
            Map<String, dynamic>.from(decoded['data']),
          );
        }
      }

      throw Exception(
        'Formato inesperado en la respuesta de /payments',
      );
    }

    throw Exception(
      'No se pudo procesar el pago (${response.statusCode}): ${response.body}',
    );
  }

  // ============================================================
  // GET /me/payments
  // ============================================================
  Future<List<Payment>> getMyPayments() async {
    final response = await _api.get('/me/payments');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      // Caso:
      // [
      //   {...},
      //   {...}
      // ]
      if (decoded is List) {
        return decoded
            .map(
              (item) => Payment.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      // Caso:
      // {
      //   "data": [
      //     {...},
      //     {...}
      //   ]
      // }
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];

        if (data is List) {
          return data
              .map(
                (item) => Payment.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();
        }
      }

      throw Exception(
        'Formato inesperado en GET /me/payments',
      );
    }

    throw Exception(
      'No se pudieron obtener los pagos (${response.statusCode}): ${response.body}',
    );
  }
}