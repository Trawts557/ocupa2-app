import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../auth/login_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionService sessionService = SessionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocupa2'),
        actions: [
          IconButton(
            onPressed: () async {
              await sessionService.deleteToken();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginView(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text('Inicio de Ocupa2'),
      ),
    );
  }
}