import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/offer.dart';
import '../../../services/offer_service.dart';
import '../../offers/offers_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState
    extends State<MyApplicationsScreen> {
  final OfferService _offerService = OfferService();

  late Future<List<Offer>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    _applicationsFuture =
        _offerService.getMyApplications();
  }

  Future<void> _refreshApplications() async {
    setState(() {
      _loadApplications();
    });

    await _applicationsFuture;
  }

  void _openOfferDetail(Offer offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfferDetailScreen(
          offer: offer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis postulaciones'),
      ),
      body: FutureBuilder<List<Offer>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                      _refreshApplications,
                      child:
                      const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final applications =
              snapshot.data ?? [];

          if (applications.isEmpty) {
            return RefreshIndicator(
              onRefresh:
              _refreshApplications,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text(
                      'No tienes postulaciones todavía.',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                        AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh:
            _refreshApplications,
            child: ListView.builder(
              padding:
              const EdgeInsets.all(16),
              itemCount:
              applications.length,
              itemBuilder:
                  (context, index) {
                final offer =
                applications[index];

                return Card(
                  margin:
                  const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: ListTile(
                    onTap: () {
                      _openOfferDetail(
                        offer,
                      );
                    },
                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading:
                    const CircleAvatar(
                      child: Icon(
                        Icons.work_outline,
                      ),
                    ),
                    title: Text(
                      offer.jobTypeName.isNotEmpty
                          ? offer.jobTypeName
                          : 'Oferta de empleo',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        if (offer.address
                            .isNotEmpty)
                          Text(
                            offer.address,
                            maxLines: 2,
                            overflow:
                            TextOverflow
                                .ellipsis,
                          ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          '${offer.payment.amount} '
                              '${offer.payment.currency}',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing:
                    const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}