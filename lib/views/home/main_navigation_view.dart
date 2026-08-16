import 'package:flutter/material.dart';

import '../profile/profile_view.dart';
import '../forum/forum_screen.dart';
import '../../services/session_service.dart';
import '../auth/login_view.dart';
import 'home_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
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
        return const Center(child: Text('Explorar ofertas'));
      case 2:
        return const Center(child: Text('Publicar oferta'));
      case 3:
        return const ForumScreen();
      case 4:
        return const ProfileView();
      default:
        return const HomeView();
    }
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