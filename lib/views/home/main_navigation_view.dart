import 'package:flutter/material.dart';

import 'package:ocupa2_app/core/theme/app_colors.dart';
import '../profile/profile_view.dart' as dashboard;
import '../forum/forum_screen.dart';
import '../offers/offers_screen.dart';
import '../employer/create_offer_screen.dart';
import '../../services/session_service.dart';
import '../auth/login_view.dart';
import 'home_view.dart';

/// Navegación principal de la app con 5 pestañas.
/// Se llama ProfileView como en el diseño original del equipo.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _getSelectedView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Ofertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_business_outlined),
            selectedIcon: Icon(Icons.add_business),
            label: 'Publicar',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Foro',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _getSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return const HomeView();
      case 1:
        return const OffersScreen();
      case 2:
        return _buildPublishLauncher();
      case 3:
        return const ForumScreen();
      case 4:
        // Usa el ALIAS para referirse al dashboard de perfil
        return const dashboard.ProfileView();
      default:
        return const HomeView();
    }
  }

  /// Pantalla de la pestaña "Publicar": lanza el flujo completo.
  Widget _buildPublishLauncher() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_business_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Necesitas contratar a alguien?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Publica una oferta y encuentra personas interesadas en realizarla.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateOfferScreen(),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Publicar oferta'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Ocupa2';
      case 1:
        return 'Explorar ofertas';
      case 2:
        return 'Publicar oferta';
      case 3:
        return 'Foro';
      case 4:
        return 'Mi perfil';
      default:
        return 'Ocupa2';
    }
  }

  Future<void> _logout() async {
    await SessionService().deleteToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }
}