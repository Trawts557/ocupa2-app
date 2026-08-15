import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ocupa2_app/core/theme/app_colors.dart';

/// Pantalla Acerca de (Persona 4).
/// Muestra al equipo: foto, nombre, matrícula, teléfono (llamada) y Telegram.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // ⚠️ EDITA AQUÍ: reemplaza con los datos reales de tu equipo.
  static const List<_TeamMember> _team = [
    _TeamMember(
      name: 'Integrante 1',
      role: 'Persona 1 · Autenticación, perfil y rutas',
      matricula: '20XXXXXX',
      phone: '+18095550001',
      telegram: 'https://t.me/usuario1',
    ),
    _TeamMember(
      name: 'Integrante 2',
      role: 'Persona 2 · Ofertas y postulaciones',
      matricula: '20XXXXXX',
      phone: '+18095550002',
      telegram: 'https://t.me/usuario2',
    ),
    _TeamMember(
      name: 'Integrante 3',
      role: 'Persona 3 · Panel de ofertas y pagos',
      matricula: '20XXXXXX',
      phone: '+18095550003',
      telegram: 'https://t.me/usuario3',
    ),
    _TeamMember(
      name: 'Jesus Gomez',
      role: 'Persona 4 · Perfil, seguimiento y contenido',
      matricula: '20198911',
      phone: '+18095550004',
      telegram: 'https://t.me/jesusgomez',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _AppHeader(),
          const SizedBox(height: 24),
          Text(
            'Equipo de desarrollo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ..._team.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TeamMemberCard(member: member),
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado con el logo y la versión de la app.
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.work, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 12),
            Text('Ocupa2', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Versión 1.0.0',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(
              'Plataforma de empleos que conecta estudiantes del ITLA '
              'con oportunidades laborales.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Datos de un integrante del equipo.
class _TeamMember {
  final String name;
  final String role;
  final String matricula;
  final String phone;
  final String telegram;
  final String? photoUrl;

  const _TeamMember({
    required this.name,
    required this.role,
    required this.matricula,
    required this.phone,
    required this.telegram,
    this.photoUrl,
  });
}

/// Tarjeta de integrante con llamada y Telegram funcionales.
class _TeamMemberCard extends StatelessWidget {
  final _TeamMember member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: member.photoUrl != null
                      ? NetworkImage(member.photoUrl!)
                      : null,
                  child: member.photoUrl == null
                      ? Text(
                          _initials(member.name),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(member.role,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text('Matrícula: ${member.matricula}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launch(
                      context,
                      Uri(scheme: 'tel', path: member.phone),
                    ),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Llamar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launch(
                      context,
                      Uri.parse(member.telegram),
                    ),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Telegram'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }
}

/// Iniciales para el avatar cuando no hay foto.
String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return (first + last).toUpperCase();
}