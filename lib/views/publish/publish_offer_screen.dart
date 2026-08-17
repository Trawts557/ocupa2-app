import 'package:flutter/material.dart';

// 1. IMPORTA AQUÍ TU PANTALLA DE PAGO
// Cambia 'card_payment_screen.dart' por la ruta real donde guardaste el archivo de pago.
import '../payments/card_payment_screen.dart';
// o prueba con:
// import 'package:ocupa2_app/views/payments/card_payment_screen.dart';

class PublishOfferScreen extends StatefulWidget {
  const PublishOfferScreen({super.key});

  @override
  State<PublishOfferScreen> createState() => _PublishOfferScreenState();
}

class _PublishOfferScreenState extends State<PublishOfferScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores basados en los requerimientos del API de ofertas
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _deadlineController = TextEditingController();

  // ignore: prefer_final_fields
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _paymentController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Nueva Oferta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del trabajo',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada',
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _paymentController,
                decoration: const InputDecoration(
                  labelText: 'Pago ofrecido (\$)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación (Ciudad/Zona)',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección exacta',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Fecha límite (YYYY-MM-DD)',
                  hintText: '2026-08-27',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  // Validación básica del formato YYYY-MM-DD
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!regex.hasMatch(value)) {
                    return 'Usa el formato YYYY-MM-DD (ej: 2026-08-27)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continuar al Pago (1 USD)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final offerData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'payment': double.tryParse(_paymentController.text.trim()) ?? 0.0,
        'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
        'deadline': _deadlineController.text.trim(),
      };

      // Debe ser 'CardPaymentScreen' (con mayúsculas)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardPaymentScreen(offerData: offerData),
        ),
      );
    }
  }
        
      
    }
  
