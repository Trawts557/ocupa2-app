import 'package:flutter/material.dart';
import 'package:ocupa2_app/models/payment.dart';
import 'package:ocupa2_app/services/payment_service.dart';

class CardPaymentScreen extends StatefulWidget {
  final PaymentService paymentService;
  final String offerId;

  const CardPaymentScreen({
    super.key,
    required this.paymentService,
    required this.offerId,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController(); // formato MM/AA
  final _cvvController = TextEditingController();

  bool _paying = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;

    final parts = _expiryController.text.split('/');
    final month = parts.isNotEmpty ? parts[0].trim() : '';
    final year = parts.length > 1 ? parts[1].trim() : '';

    setState(() => _paying = true);
    try {
      final payment = await widget.paymentService.payForOffer(
        offerId: widget.offerId,
        cardholderName: _nameController.text.trim(),
        cardNumber: _numberController.text.replaceAll(' ', ''),
        expiryMonth: month,
        expiryYear: year,
        cvv: _cvvController.text.trim(),
      );

      if (mounted) Navigator.pop<Payment>(context, payment);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo procesar el pago: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago de publicación')),
      body: _paying
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Se cobrará 1.00 USD para publicar tu oferta.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre en la tarjeta'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Número de tarjeta',
                      hintText: '4242 4242 4242 4242',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    validator: (v) {
                      final digits = (v ?? '').replaceAll(' ', '');
                      if (digits.length < 13 || digits.length > 19) {
                        return 'Número de tarjeta inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          decoration: const InputDecoration(
                            labelText: 'Vencimiento',
                            hintText: 'MM/AA',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
                              return 'Formato MM/AA';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: const InputDecoration(labelText: 'CVV'),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          validator: (v) {
                            if (v == null || v.length < 3) return 'CVV inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _pay,
                    child: const Text('Pagar 1.00 USD'),
                  ),
                ],
              ),
            ),
    );
  }
}