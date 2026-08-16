import 'package:flutter/material.dart';
import 'package:ocupa2_app/models/offer.dart';
import 'package:ocupa2_app/models/application.dart';
import 'package:ocupa2_app/services/publish_service.dart';
import 'package:ocupa2_app/services/contract_service.dart';
import 'contract_confirmation_screen.dart';

class OfferApplicantsScreen extends StatefulWidget {
  final Offer offer;
  final PublishService publishService;
  final ContractService contractService;

  const OfferApplicantsScreen({
    super.key,
    required this.offer,
    required this.publishService,
    required this.contractService,
  });

  @override
  State<OfferApplicantsScreen> createState() =>
      _OfferApplicantsScreenState();
}

class _OfferApplicantsScreenState extends State<OfferApplicantsScreen> {
  late Future<List<Application>> _future;

  @override
  void initState() {
    super.initState();

    _future = widget.publishService.getOfferApplications(
      widget.offer.id,
    );
  }

  Future<void> _updateStatus(
    Application app,
    String status,
  ) async {
    // El ID es nullable en el modelo.
    // Verificamos antes de enviarlo al servicio.
    if (app.id == null || app.id!.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se encontró el ID de la aplicación.',
          ),
        ),
      );

      return;
    }

    try {
      await widget.publishService.updateApplication(
        app.id!,
        status: status,
      );

      if (!mounted) return;

      // Si seleccionamos ganador,
      // mostramos la pantalla del contrato.
      if (status == 'ganador') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContractConfirmationScreen(
              contractService: widget.contractService,
              offerId: widget.offer.id,
            ),
          ),
        );
      }

      if (!mounted) return;

      // Recargar aplicantes.
      setState(() {
        _future = widget.publishService.getOfferApplications(
          widget.offer.id,
        );
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al actualizar aplicación: $e',
          ),
        ),
      );
    }
  }

  /// Obtiene el nombre del aplicante.
  ///
  /// El modelo Application no tiene applicantName,
  /// por eso buscamos diferentes estructuras posibles
  /// dentro de raw.
  String _getApplicantName(Application app) {
    final raw = app.raw;

    // Caso:
    // {
    //   "applicantName": "Juan"
    // }
    final directName = raw['applicantName'];

    if (directName != null &&
        directName.toString().trim().isNotEmpty) {
      return directName.toString();
    }

    // Caso:
    // {
    //   "applicant": {
    //      "name": "Juan"
    //   }
    // }
    final applicant = raw['applicant'];

    if (applicant is Map) {
      final name =
          applicant['name'] ??
          applicant['full_name'] ??
          applicant['fullname'] ??
          applicant['nombre'];

      if (name != null &&
          name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    // Caso:
    // {
    //   "user": {
    //      "name": "Juan"
    //   }
    // }
    final user = raw['user'];

    if (user is Map) {
      final name =
          user['name'] ??
          user['full_name'] ??
          user['fullname'] ??
          user['nombre'];

      if (name != null &&
          name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    // Caso:
    // {
    //   "candidate": {
    //      "name": "Juan"
    //   }
    // }
    final candidate = raw['candidate'];

    if (candidate is Map) {
      final name =
          candidate['name'] ??
          candidate['full_name'] ??
          candidate['fullname'] ??
          candidate['nombre'];

      if (name != null &&
          name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    // Otros posibles campos directos.
    final fallback =
        raw['name'] ??
        raw['full_name'] ??
        raw['fullname'] ??
        raw['nombre'];

    if (fallback != null &&
        fallback.toString().trim().isNotEmpty) {
      return fallback.toString();
    }

    return 'Aplicante';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplicantes'),
      ),
      body: FutureBuilder<List<Application>>(
        future: _future,
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
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error al cargar aplicantes:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final apps = snapshot.data ?? <Application>[];

          if (apps.isEmpty) {
            return const Center(
              child: Text(
                'Sin aplicantes todavía',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future =
                    widget.publishService.getOfferApplications(
                  widget.offer.id,
                );
              });

              await _future;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];

                final applicantName =
                    _getApplicantName(app);

                final comment =
                    app.comment ?? 'Sin comentario';

                final status =
                    app.status ?? 'Sin estado';

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      applicantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '$comment\nEstado: $status',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (selectedStatus) {
                        _updateStatus(
                          app,
                          selectedStatus,
                        );
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'descartado',
                          child: Text('Descartar'),
                        ),
                        PopupMenuItem(
                          value: 'finalista',
                          child: Text(
                            'Marcar finalista',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'ganador',
                          child: Text(
                            'Elegir ganador',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}