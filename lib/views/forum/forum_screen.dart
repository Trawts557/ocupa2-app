import 'package:flutter/material.dart';

import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/models/forum.dart';
import 'package:ocupa2_app/services/forum_service.dart';
import 'package:ocupa2_app/views/forum/forum_topic_detail_screen.dart';

/// Pantalla del Foro: lista de temas + crear tema nuevo.
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  late final ForumService _forumService;
  Future<List<ForumTopic>>? _futureTopics;

  @override
  void initState() {
    super.initState();
    _forumService = ForumService(apiClient: ApiClient());
    _loadTopics();
  }

  void _loadTopics() {
    setState(() {
      _futureTopics = _forumService.getTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ForumTopic>>(
        future: _futureTopics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error al cargar el foro',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: _loadTopics,
                        child: const Text('Reintentar')),
                  ],
                ),
              ),
            );
          }

          final topics = snapshot.data ?? [];

          if (topics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined,
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Aún no hay temas en el foro',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Toca + para iniciar la primera discusión',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return _TopicCard(topic: topics[index]);
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateTopicDialog(forumService: _forumService),
    );

    if (created == true) _loadTopics();
  }
}

/// Tarjeta de un tema de la lista.
class _TopicCard extends StatelessWidget {
  final ForumTopic topic;

  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ForumTopicDetailScreen(topicId: topic.id ?? ''),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.title ?? 'Tema sin título',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (topic.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  topic.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      topic.author?.nombre ?? 'Anónimo',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chat_bubble_outline,
                      size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    '${topic.commentsCount ?? 0}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (topic.createdAt != null) ...[
                    const SizedBox(width: 12),
                    Text(_formatDate(topic.createdAt),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

/// Diálogo para crear un tema (title y description obligatorios).
class _CreateTopicDialog extends StatefulWidget {
  final ForumService forumService;

  const _CreateTopicDialog({required this.forumService});

  @override
  State<_CreateTopicDialog> createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends State<_CreateTopicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo tema'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: '¿Dónde consiguieron su primer empleo?',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Escribe un título'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Cuenten su experiencia...',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Escribe una descripción'
                        : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.forumService.createTopic(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}