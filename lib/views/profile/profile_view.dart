import 'package:flutter/material.dart';

import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/views/profile/experiences_screen.dart';
import 'package:ocupa2_app/views/applications/tracking/applications_tracking_screen.dart';
import 'package:ocupa2_app/views/news/news_screen.dart';
import 'package:ocupa2_app/views/videos/videos_screen.dart';
import 'package:ocupa2_app/views/about/about_screen.dart';
import 'package:ocupa2_app/views/auth/change_password_view.dart';

/// Dashboard principal del perfil (Persona 4).
/// Contiene accesos a: Experiencias, Aplicaciones, Noticias, Videos,
/// Acerca de y Cambiar contraseña.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            _ProfileMenuCard(
              icon: Icons.work_outline,
              title: 'Mis Experiencias',
              subtitle: 'Gestiona tu historial laboral y certificados',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExperiencesScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _ProfileMenuCard(
              icon: Icons.send_outlined,
              title: 'Mis Aplicaciones',
              subtitle: 'Revisa el estado de tus postulaciones',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ApplicationsTrackingScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            _ProfileMenuCard(
              icon: Icons.newspaper_outlined,
              title: 'Noticias',
              subtitle: 'Novedades sobre empleo y la plataforma',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewsScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _ProfileMenuCard(
              icon: Icons.play_circle_outline,
              title: 'Videos',
              subtitle: 'Tutoriales y capacitaciones',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VideosScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _ProfileMenuCard(
              icon: Icons.info_outline,
              title: 'Acerca de',
              subtitle: 'Información del equipo de desarrollo',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
            const SizedBox(height: 12),

            // NUEVO: acceso al módulo de Persona 1
            _ProfileMenuCard(
              icon: Icons.lock_outline,
              title: 'Cambiar contraseña',
              subtitle: 'Actualiza la contraseña de tu cuenta',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordView()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta reutilizable para el menú del perfil.
class _ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}