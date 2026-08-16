import 'package:flutter/material.dart';
import 'package:ocupa2_app/models/offer.dart';
import 'package:ocupa2_app/models/application.dart';
import 'package:ocupa2_app/services/publish_service.dart';

class OfferApplicantsScreen extends StatefulWidget {
  final Offer offer;
  final PublishService publishService;

  const OfferApplicantsScreen({
    super.key,
    required this.offer,
    required this.publishService,
  });

  @override
  State<OfferApplicantsScreen> createState() => _OfferApplicantsScreenState();
}

class _OfferApplicantsScreenState extends State<OfferApplicantsScreen> {
  late Future<List<Application>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.publishService.getOfferApplications(widget.offer.id);
  }

  Future<void> _updateStatus(Application app, String status) async {
    await widget.publishService.updateApplication(app.id, status: status);
    setState(() {
      _future = widget.publishService.getOfferApplications(widget.offer.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aplicantes')),
      body: FutureBuilder<List<Application>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final apps = snapshot.data ?? [];
          if (apps.isEmpty) {
            return const Center(child: Text('Sin aplicantes todavía'));
          }
          return ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, i) {
              final app = apps[i];
              return Card(
                child: ListTile(
                  title: Text(app.applicantName),
                  subtitle: Text('${app.comment}\nEstado: ${app.status}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (status) => _updateStatus(app, status),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'descartado', child: Text('Descartar')),
                      PopupMenuItem(value: 'finalista', child: Text('Marcar finalista')),
                      PopupMenuItem(value: 'ganador', child: Text('Elegir ganador')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}