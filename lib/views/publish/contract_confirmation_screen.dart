import 'package:flutter/material.dart';
import 'package:ocupa2_app/models/contract.dart';
import 'package:ocupa2_app/services/contract_service.dart';

class ContractConfirmationScreen extends StatefulWidget {
  final ContractService contractService;
  final String offerId;

  const ContractConfirmationScreen({
    super.key,
    required this.contractService,
    required this.offerId,
  });

  @override
  State<ContractConfirmationScreen> createState() => _ContractConfirmationScreenState();
}

class _ContractConfirmationScreenState extends State<ContractConfirmationScreen> {
  late Future<List<Contract>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.contractService.getMyContracts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contrato generado')),
      body: FutureBuilder<List<Contract>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final contracts = snapshot.data ?? [];
          if (contracts.isEmpty) {
            return const Center(child: Text('Aún no aparece el contrato — intenta refrescar.'));
          }

          final match = contracts.firstWhere(
            (c) => c.offerId == widget.offerId,
            orElse: () => contracts.first,
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Card(
                  color: Colors.green.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¡Contrato generado! La plataforma lo crea automáticamente '
                            'al elegir ganador.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _row('ID del contrato', match.id),
                if (match.jobTypeName != null) _row('Tipo de empleo', match.jobTypeName!),
                _row('Tu rol', match.myRole ?? '—'),
                if (match.contratado.name != null)
                  _row('Contratado', match.contratado.name!),
                if (match.salary != null)
                  _row('Salario', '${match.salary!.toStringAsFixed(2)} ${match.currency ?? ''}'),
                if (match.startDate != null)
                  _row('Fecha de inicio', match.startDate!.toString().split(' ').first),
                if (match.duration != null) _row('Duración', match.duration!),
                _row('Estado', match.status ?? '—'),
                if (match.createdAt != null)
                  _row('Creado', match.createdAt!.toString().split('.').first),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}