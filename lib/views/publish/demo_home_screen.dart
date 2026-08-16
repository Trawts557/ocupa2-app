import 'package:flutter/material.dart';
import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/services/publish_service.dart';
import 'package:ocupa2_app/services/payment_service.dart';
import 'package:ocupa2_app/services/contract_service.dart';
import 'publish_offer_screen.dart';
import 'my_offers_screen.dart';

class DemoHomeScreen extends StatefulWidget {
  final ApiClient apiClient;

  const DemoHomeScreen({super.key, required this.apiClient});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  final _tokenController = TextEditingController();
  bool _tokenSaved = false;

  @override
  void initState() {
    super.initState();
    _tokenSaved = widget.apiClient.jwt != null && widget.apiClient.jwt!.isNotEmpty;
  }

  void _saveToken() {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;
    setState(() {
      widget.apiClient.jwt = token;
      _tokenSaved = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token guardado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final publishService = PublishService(widget.apiClient);
    final paymentService = PaymentService(widget.apiClient);
    final contractService = ContractService(widget.apiClient);

    return Scaffold(
      appBar: AppBar(title: const Text('Ocupa2 — Flujo Persona 3')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_tokenSaved) ...[
              const Text(
                'Pega aquí tu JWT (obtenido desde Swagger) para poder probar el flujo:',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'JWT',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveToken,
                child: const Text('Guardar token'),
              ),
              const SizedBox(height: 24),
            ] else ...[
              const Card(
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    '✓ Token guardado — ya puedes probar el flujo',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            ElevatedButton.icon(
              icon: const Icon(Icons.add_business),
              label: const Text('Publicar oferta'),
              onPressed: !_tokenSaved
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublishOfferScreen(
                            publishService: publishService,
                            paymentService: paymentService,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Mis ofertas publicadas'),
              onPressed: !_tokenSaved
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyOffersScreen(
                            publishService: publishService,
                            contractService: contractService,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}