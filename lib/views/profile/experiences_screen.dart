import 'dart:io';
import 'package:ocupa2_app/views/profile/experience_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/models/experience.dart';
import 'package:ocupa2_app/services/experience_service.dart';

/// Pantalla de Perfil / Experiencias (Persona 4).
///
/// Carpeta: lib/views/profile/
/// Endpoints que consume (a través de ExperienceService):
/// - GET    /me/experiences
/// - POST   /me/experiences
/// - DELETE /me/experiences/{id}
/// - POST   /uploads (certificado en Base64)
class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  late final ExperienceService _experienceService;
  Future<List<Experience>>? _futureExperiences;

  @override
  void initState() {
    super.initState();
    // ApiClient de Persona 1 (core/networks/): el JWT se inyecta solo.
    // Si el equipo adopta inyección de dependencias, cambia solo esta línea.
    _experienceService = ExperienceService(apiClient: ApiClient());
    _loadExperiences();
  }

  void _loadExperiences() {
    setState(() {
      _futureExperiences = _experienceService.getMyExperiences();
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteExperience(Experience experience) async {
    if (experience.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar experiencia'),
        content: Text('¿Seguro que deseas eliminar "${experience.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _experienceService.deleteExperience(experience.id!);
      _loadExperiences();
      _showSnackBar('Experiencia eliminada correctamente');
    } catch (e) {
      _showSnackBar('Error al eliminar: $e');
    }
  }

  void _showAddExperienceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExperienceModal(
        service: _experienceService,
        onSaved: _loadExperiences,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Experiencias')),
      body: FutureBuilder<List<Experience>>(
        future: _futureExperiences,
        builder: (context, snapshot) {
          // 1) Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar tus experiencias',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadExperiences,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final experiences = snapshot.data ?? [];

          // 3) Vacío
          if (experiences.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes experiencias registradas',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Presiona el botón "Agregar" para crear la primera',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // 4) Éxito
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: experiences.length,
            itemBuilder: (context, index) {
              final experience = experiences[index];
              return _ExperienceCard(
                experience: experience,
                onDelete: () => _deleteExperience(experience),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExperienceModal,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        backgroundColor: AppColors.secondary, // Naranja: acción principal
      ),
    );
  }
}

/// Tarjeta individual de experiencia.
/// Tarjeta individual de experiencia (ahora clickeable).
class _ExperienceCard extends StatelessWidget {
  final Experience experience;
  final VoidCallback onDelete;

  const _ExperienceCard({
    required this.experience,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CertificateThumb(url: experience.certificateUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experience.title ?? 'Sin título',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          experience.description ?? 'Sin descripción',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (experience.startDate != null || experience.endDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(experience.startDate)} - ${_formatDate(experience.endDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Toca para ver detalles',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExperienceDetailScreen(experience: experience),
      ),
    );
  }
}

/// Miniatura del certificado (o placeholder si no hay imagen).
class _CertificateThumb extends StatelessWidget {
  final String? url;

  const _CertificateThumb({this.url});

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
        child: Icon(Icons.work_outline, color: AppColors.primary),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 56,
            height: 56,
            color: AppColors.primary.withValues(alpha: 0.1),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 56,
            height: 56,
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.broken_image, color: AppColors.primary),
          );
        },
      ),
    );
  }
}

/// Modal para agregar una nueva experiencia con certificado opcional.
class _AddExperienceModal extends StatefulWidget {
  final ExperienceService service;
  final VoidCallback onSaved;

  const _AddExperienceModal({
    required this.service,
    required this.onSaved,
  });

  @override
  State<_AddExperienceModal> createState() => _AddExperienceModalState();
}

class _AddExperienceModalState extends State<_AddExperienceModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _certificateImage;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _certificateImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _saveExperience() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final File? certFile =
          _certificateImage != null ? File(_certificateImage!.path) : null;

      await widget.service.createExperienceWithCertificate(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        certificateFile: certFile,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experiencia agregada correctamente')),
        );
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nueva Experiencia',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título / Puesto',
                  hintText: 'Ej: Plomero, Chofer, Electricista',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'El título es obligatorio'
                        : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe tus funciones y logros',
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'La descripción es obligatoria'
                        : null,
              ),
              const SizedBox(height: 16),

              // Fechas opcionales
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _pickStartDate,
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: Text(
                        _startDate == null
                            ? 'Fecha inicio'
                            : _formatDate(_startDate),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _pickEndDate,
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: Text(
                        _endDate == null ? 'Fecha fin' : _formatDate(_endDate),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Certificado opcional
              Text(
                'Certificado (opcional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (_certificateImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_certificateImage!.path),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => setState(() => _certificateImage = null),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Quitar imagen'),
                  ),
                ),
              ],
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _pickImage,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _certificateImage == null
                      ? 'Seleccionar imagen'
                      : 'Cambiar imagen',
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveExperience,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar Experiencia'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formato de fecha corto dd/mm/yyyy compartido por tarjeta y modal.
String _formatDate(DateTime? date) {
  if (date == null) return 'Actualidad';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}