import 'package:flutter/material.dart';

import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/models/experience.dart';

/// Pantalla de detalle completo de una experiencia.
class ExperienceDetailScreen extends StatelessWidget {
  final Experience experience;

  const ExperienceDetailScreen({
    super.key,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Experiencia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificado (si existe)
            if (experience.certificateUrl != null &&
                experience.certificateUrl!.isNotEmpty) ...[
              _CertificatePreview(url: experience.certificateUrl!),
              const SizedBox(height: 24),
            ],

            // Título
            Text(
              experience.title ?? 'Sin título',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Fechas
            if (experience.startDate != null || experience.endDate != null) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(experience.startDate)} - ${_formatDate(experience.endDate)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Descripción
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                experience.description ?? 'Sin descripción disponible.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),

            // Metadata adicional
            if (experience.createdAt != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Creada el ${_formatDate(experience.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],

            if (experience.updatedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.update, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Actualizada el ${_formatDate(experience.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Actualidad';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

/// Widget para mostrar el certificado con opción de ampliar
class _CertificatePreview extends StatelessWidget {
  final String url;

  const _CertificatePreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Ver completo',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 100, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}