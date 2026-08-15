import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          Text(
            'Encuentra oportunidades cerca de ti',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 12),

          Text(
            'Ocupa2 conecta personas que necesitan realizar un trabajo '
            'con personas dispuestas a hacerlo.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 28),

          _buildPresentationCard(
            context,
            icon: Icons.search,
            title: 'Encuentra oportunidades',
            description:
                'Explora ofertas de trabajo y encuentra la que mejor se adapte a ti.',
          ),

          const SizedBox(height: 12),

          _buildPresentationCard(
            context,
            icon: Icons.work_outline,
            title: 'Publica trabajos',
            description:
                'Publica una necesidad y encuentra personas interesadas en realizarla.',
          ),

          const SizedBox(height: 12),

          _buildPresentationCard(
            context,
            icon: Icons.handshake_outlined,
            title: 'Conecta y trabaja',
            description:
                'Gestiona tus aplicaciones y contratos desde un mismo lugar.',
          ),

          const SizedBox(height: 28),

          Center(
            child: Text(
              'Tu próxima oportunidad puede estar más cerca de lo que imaginas.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPresentationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              icon,
              size: 38,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 6),

                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}