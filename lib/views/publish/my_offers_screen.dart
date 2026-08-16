import 'package:flutter/material.dart';
import 'package:ocupa2_app/models/offer.dart';
import 'package:ocupa2_app/services/publish_service.dart';
import 'offer_applicants_screen.dart'; 

class MyOffersScreen extends StatefulWidget {
  final PublishService publishService;
  const MyOffersScreen({super.key, required this.publishService});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  late Future<List<Offer>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.publishService.getMyOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis ofertas publicadas')),
      body: FutureBuilder<List<Offer>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final offers = snapshot.data ?? [];
          if (offers.isEmpty) {
            return const Center(child: Text('Aún no has publicado ofertas'));
          }
          return ListView.builder(
            itemCount: offers.length,
            itemBuilder: (context, i) {
              final offer = offers[i];
              return Card(
                child: ListTile(
                  title: Text(offer.description),
                  subtitle: Text(offer.address),
                  trailing: offer.active
                      ? const Icon(Icons.circle, color: Colors.green, size: 12)
                      : const Icon(Icons.circle, color: Colors.grey, size: 12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfferApplicantsScreen(
                        offer: offer,
                        publishService: widget.publishService,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}