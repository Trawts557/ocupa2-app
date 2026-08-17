import 'package:flutter/material.dart';

class CardPaymentScreen extends StatelessWidget {
  final Map<String, dynamic> offerData;

  const CardPaymentScreen({super.key, required this.offerData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasarela de Pago (1 USD)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de la oferta:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Título: ${offerData['title']}'),
            Text('Descripción: ${offerData['description']}'),
            Text('Pago ofrecido: \$${offerData['payment']}'),
            Text('Ubicación: ${offerData['location']}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Aquí procesarías el pago y enviarías la oferta a tu API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Pago simulado con éxito!')),
                );
              },
              child: const Text('Pagar 1 USD y Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}