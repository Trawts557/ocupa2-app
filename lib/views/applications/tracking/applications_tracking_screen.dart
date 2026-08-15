import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/models/application.dart';
import 'package:ocupa2_app/services/application_service.dart';

/// Pantalla de seguimiento de aplicaciones (Persona 4).
///
/// Carpeta: lib/views/applications/tracking/
/// Endpoint: GET /me/applications
/// Privacidad: los datos del empleador solo se muestran si eres GANADOR.
class ApplicationsTrackingScreen extends StatefulWidget {
  const ApplicationsTrackingScreen({super.key});

  @override
  State<ApplicationsTrackingScreen> createState() =>
      _ApplicationsTrackingScreenState();
}

class _ApplicationsTrackingScreenState
    extends State<ApplicationsTrackingScreen> {
  late final ApplicationService _applicationService;
  Future<List<Application>>? _futureApplications;

  @override
  void initState() {
    super.initState();
    _applicationService = ApplicationService(apiClient: ApiClient());
    _loadApplications();
  }

  void _loadApplications() {
    setState(() {
      _futureApplications = _applicationService.getMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Aplicaciones')),
      body: FutureBuilder<List<Application>>(
        future: _futureApplications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.error_outline,
              title: 'Error al cargar tus aplicaciones',
              subtitle: snapshot.error.toString(),
              actionLabel: 'Reintentar',
              onAction: _loadApplications,
            );
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return const _StateMessage(
              icon: Icons.send_outlined,
              title: 'Aún no has aplicado a ninguna oferta',
              subtitle:
                  'Cuando apliques a ofertas, aquí verás su estado:\n'
                  'en revisión, descartado, finalista o ganador.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              return _ApplicationCard(application: applications[index]);
            },
          );
        },
      ),
    );
  }
}

/// Tarjeta de una aplicación con su estado y (si eres ganador) el empleador.
class _ApplicationCard extends StatelessWidget {
  final Application application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final offer = application.offer;
    final employerName = offer?.employerName;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OfferThumb(url: offer?.photoUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer?.title ?? 'Oferta sin título',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (offer?.jobType != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          offer!.jobType!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusChip(status: application.statusEnum),
              ],
            ),
            if (application.createdAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Aplicaste el ${_formatDate(application.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (application.isWinner && employerName != null)
              _WinnerContact(name: employerName, phone: offer?.employerPhone)
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'La identidad del empleador se revelará si eres '
                  'seleccionado como ganador.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chip con el estado de la aplicación usando los colores semánticos.
class _StatusChip extends StatelessWidget {
  final ApplicationStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (status) {
      case ApplicationStatus.review:
        return AppColors.info;
      case ApplicationStatus.discarded:
        return AppColors.danger;
      case ApplicationStatus.finalist:
        return AppColors.warning;
      case ApplicationStatus.winner:
        return AppColors.success;
      case ApplicationStatus.unknown:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (status) {
      case ApplicationStatus.review:
        return Icons.hourglass_top;
      case ApplicationStatus.discarded:
        return Icons.cancel_outlined;
      case ApplicationStatus.finalist:
        return Icons.stars_outlined;
      case ApplicationStatus.winner:
        return Icons.emoji_events_outlined;
      case ApplicationStatus.unknown:
        return Icons.help_outline;
    }
  }

  String get _label {
    switch (status) {
      case ApplicationStatus.review:
        return 'En revisión';
      case ApplicationStatus.discarded:
        return 'Descartado';
      case ApplicationStatus.finalist:
        return 'Finalista';
      case ApplicationStatus.winner:
        return 'Ganador';
      case ApplicationStatus.unknown:
        return 'Sin estado';
    }
  }
}

/// Bloque que revela al empleador SOLO cuando eres ganador.
class _WinnerContact extends StatelessWidget {
  final String name;
  final String? phone;

  const _WinnerContact({required this.name, this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.celebration, size: 18, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡Felicidades! Fuiste seleccionado como ganador.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Empleador: $name',
              style: Theme.of(context).textTheme.bodyMedium),
          if (phone != null) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _call(phone!),
              icon: const Icon(Icons.call, size: 18),
              label: const Text('Llamar al empleador'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Miniatura de la foto de la oferta (o placeholder).
class _OfferThumb extends StatelessWidget {
  final String? url;

  const _OfferThumb({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.work_outline, color: AppColors.primary),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 56,
          height: 56,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.broken_image, color: AppColors.primary),
        ),
      ),
    );
  }
}

/// Mensaje reutilizable para estados vacío y error.
class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '—';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}