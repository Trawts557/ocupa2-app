import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/models/payment.dart';

class PaymentService {
  final ApiClient _api;
  PaymentService(this._api);

  // POST /payments  → cobro de 1 USD para publicar
  // ⚠️ Confirmar en Swagger el nombre exacto de estos campos
  Future<Payment> payForOffer({
    required String offerId,
    required String cardholderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    final data = await _api.post('/payments', {
      'offer_id': offerId,
      'amount': 1.00,
      'cardholder_name': cardholderName,
      'card_number': cardNumber,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cvv': cvv,
    });
    return Payment.fromJson(data);
  }

  // GET /me/payments
  Future<List<Payment>> getMyPayments() async {
    final data = await _api.get('/me/payments');
    return (data as List).map((e) => Payment.fromJson(e)).toList();
  }
}