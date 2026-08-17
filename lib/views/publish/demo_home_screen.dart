import 'package:flutter/material.dart';
import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/services/publish_service.dart';
import 'package:ocupa2_app/services/contract_service.dart';

import 'publish_offer_screen.dart';
import 'my_offers_screen.dart';

class DemoHomeScreen extends StatelessWidget {
  final ApiClient apiClient;

  const DemoHomeScreen({
    super.key,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    final publishService = PublishService(apiClient);
    final contractService = ContractService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocupa2 — Publicar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sesión iniciada.\n'
                  'Puedes administrar tus ofertas desde aquí.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.add_business),
              label: const Text('Publicar oferta'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublishOfferScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Mis ofertas publicadas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyOffersScreen(
                      publishService: publishService,
                      contractService: contractService,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}