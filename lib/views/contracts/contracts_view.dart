import 'package:flutter/material.dart';

import '../../services/contract_service.dart';
import 'contract_detail_view.dart';

class ContractsView extends StatefulWidget {
  const ContractsView({super.key});

  @override
  State<ContractsView> createState() => _ContractsViewState();
}

class _ContractsViewState extends State<ContractsView> {
  final ContractService _contractService = ContractService();

  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis contratos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Filtrar por estado',
                prefixIcon: Icon(Icons.filter_alt_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('Todos'),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Activos'),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text('Inactivos'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _contractService.getMyContracts(
                status: _selectedStatus,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final contracts = snapshot.data ?? [];

                if (contracts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tienes contratos disponibles.',
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    24,
                  ),
                  itemCount: contracts.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (context, index) {
                    final contract =
                        contracts[index] as Map<String, dynamic>;

                    return _buildContractCard(contract);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractCard(
    Map<String, dynamic> contract,
  ) {
    final String id =
        contract['id']?.toString() ?? '';

    final String jobTypeName =
        contract['jobTypeName']?.toString() ??
        'Trabajo';

    final String status =
        contract['status']?.toString() ??
        'Sin estado';

    final String role =
        contract['myRole']?.toString() ??
        'Sin rol';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: id.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ContractDetailView(
                      contractId: id,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                jobTypeName,
                style:
                    Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text('Estado: $status'),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text('Rol: $role'),
                ],
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: id.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ContractDetailView(
                                contractId: id,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(
                    Icons.arrow_forward,
                  ),
                  label: const Text('Ver detalle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}