import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/models/news.dart';
import 'package:ocupa2_app/services/news_service.dart';

/// Pantalla de Noticias (Persona 4). Endpoint: GET /news
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final NewsService _newsService;
  Future<List<News>>? _futureNews;

  @override
  void initState() {
    super.initState();
    _newsService = NewsService(apiClient: ApiClient());
    _loadNews();
  }

  void _loadNews() {
    setState(() {
      _futureNews = _newsService.getNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias')),
      body: FutureBuilder<List<News>>(
        future: _futureNews,
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
                    Text('Error al cargar las noticias',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: _loadNews, child: const Text('Reintentar')),
                  ],
                ),
              ),
            );
          }

          final news = snapshot.data ?? [];

          if (news.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.newspaper,
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No hay noticias disponibles',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: news.length,
            itemBuilder: (context, index) {
              return _NewsCard(news: news[index]);
            },
          );
        },
      ),
    );
  }
}

/// Tarjeta de noticia; al tocarla abre el detalle.
class _NewsCard extends StatelessWidget {
  final News news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NewsImage(url: news.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title ?? 'Sin título',
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (news.summary != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      news.summary!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.public,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          news.source ?? 'Ocupa2',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (news.publishedAt != null)
                        Text(
                          _formatDate(news.publishedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Imagen de la noticia con placeholder.
class _NewsImage extends StatelessWidget {
  final String? url;

  const _NewsImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        color: AppColors.primary.withValues(alpha: 0.1),
        child:
            const Icon(Icons.newspaper, size: 48, color: AppColors.primary),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(
        url!,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 160,
          width: double.infinity,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.broken_image,
              size: 48, color: AppColors.primary),
        ),
      ),
    );
  }
}

/// Detalle completo de la noticia.
class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl != null && news.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(news.title ?? 'Sin título',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.public, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(news.source ?? 'Ocupa2',
                    style: Theme.of(context).textTheme.bodySmall),
                if (news.publishedAt != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(_formatDate(news.publishedAt),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
            const Divider(height: 32),
            Text(
              news.content ?? news.summary ?? 'Sin contenido disponible.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (news.linkUrl != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _openLink(news.linkUrl!),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Ver noticia completa'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // No se pudo abrir el enlace; no rompemos la app.
    }
  }
}

/// Formato de fecha compartido. Acepta nulos para evitar errores de tipo.
String _formatDate(DateTime? date) {
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}