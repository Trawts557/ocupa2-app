import 'package:flutter/material.dart';
import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/models/offer.dart';
import 'package:ocupa2_app/services/offer_service.dart';
import 'package:ocupa2_app/services/employer_service.dart';
import 'offer_applicants_screen.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  late final OfferService _offerService;
  late final EmployerService _employerService;
  Future<List<Offer>>? _future;

  @override
  void initState() {
    super.initState();
    _offerService = OfferService();
    _employerService = EmployerService(apiClient: ApiClient());
    _load();
  }

  void _load() {
    setState(() {
      _future = _offerService.getMyOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis ofertas')),
      body: FutureBuilder<List<Offer>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error al cargar tus ofertas',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: _load, child: const Text('Reintentar')),
                ],
              ),
            );
          }

          final offers = snapshot.data ?? [];

          if (offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_business_outlined,
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Aún no has publicado ofertas',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) => _OfferCard(
              offer: offers[index],
              employerService: _employerService,
              onReload: _load,
            ),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final EmployerService employerService;
  final VoidCallback onReload;

  const _OfferCard({
    required this.offer,
    required this.employerService,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.jobTypeName,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              offer.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (offer.address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      offer.address,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OfferApplicantsScreen(
                          offerId: offer.id,
                          offerTitle: offer.jobTypeName,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text('Ver aplicantes'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Desactivar oferta',
                  color: AppColors.danger,
                  icon: const Icon(Icons.block),
                  onPressed: () => _confirmDeactivate(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar oferta'),
        content: const Text(
            'Los usuarios ya no podrán aplicar a esta oferta. ¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Desactivar')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await employerService.deactivateOffer(offer.id);
      onReload();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oferta desactivada')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }
}