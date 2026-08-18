import 'package:flutter/material.dart';
import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/models/employer.dart';
import 'package:ocupa2_app/services/employer_service.dart';

class OfferApplicantsScreen extends StatefulWidget {
  final String offerId;
  final String offerTitle;

  const OfferApplicantsScreen({
    super.key,
    required this.offerId,
    required this.offerTitle,
  });

  @override
  State<OfferApplicantsScreen> createState() => _OfferApplicantsScreenState();
}

class _OfferApplicantsScreenState extends State<OfferApplicantsScreen> {
  late final EmployerService _service;
  Future<List<Applicant>>? _future;

  @override
  void initState() {
    super.initState();
    _service = EmployerService(apiClient: ApiClient());
    _load();
  }

  void _load() {
    setState(() {
      _future = _service.getApplicants(widget.offerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aplicantes: ${widget.offerTitle}')),
      body: FutureBuilder<List<Applicant>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56),
                  const SizedBox(height: 12),
                  const Text('No se pudieron cargar los aplicantes'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _load, child: const Text('Reintentar')),
                ],
              ),
            );
          }

          final applicants = snapshot.data ?? [];

          if (applicants.isEmpty) {
            return const Center(
              child: Text('Esta oferta aún no tiene aplicantes.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applicants.length,
            itemBuilder: (context, index) => _ApplicantCard(
              applicant: applicants[index],
              service: _service,
              onChanged: _load,
            ),
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Applicant applicant;
  final EmployerService service;
  final VoidCallback onChanged;

  const _ApplicantCard({
    required this.applicant,
    required this.service,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = (applicant.status ?? 'applied').toLowerCase();
    final isWinner = status == 'winner';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: applicant.photoUrl != null
                      ? NetworkImage(applicant.photoUrl!)
                      : null,
                  child: applicant.photoUrl == null
                      ? Text(
                          _initial(applicant.name),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name ?? 'Aplicante',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (applicant.createdAt != null)
                        Text(_formatDate(applicant.createdAt),
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            if (applicant.comment != null) ...[
              const SizedBox(height: 8),
              Text('"${applicant.comment}"',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (!isWinner) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _ActionButton(
                    label: 'Descartar',
                    color: AppColors.danger,
                    onTap: () => _apply(context, status: 'discarded'),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    label: 'Finalista',
                    color: AppColors.warning,
                    onTap: () => _apply(context, status: 'finalist'),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    label: 'Ganador 🏆',
                    color: AppColors.success,
                    onTap: () => _confirmWinner(context),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _apply(
    BuildContext context, {
    String? status,
    int? rating,
  }) async {
    if (!context.mounted) return;
    try {
      await service.updateApplication(
        applicant.id ?? '',
        status: status,
        rating: rating,
      );
      onChanged();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _confirmWinner(BuildContext context) async {
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar ganador 🏆'),
        content: Text(
            'Vas a elegir a ${applicant.name ?? 'este aplicante'} como ganador. '
            'Esto generará un CONTRATO entre ambos. ¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Elegir ganador')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _apply(context, status: 'winner');
    }
  }

  String _initial(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'discarded':
        color = AppColors.danger;
        label = 'Descartado';
        break;
      case 'finalist':
        color = AppColors.warning;
        label = 'Finalista';
        break;
      case 'winner':
        color = AppColors.success;
        label = 'Ganador';
        break;
      default:
        color = AppColors.info;
        label = 'En revisión';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}