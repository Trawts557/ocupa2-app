import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/offer.dart';
import '../../services/offer_service.dart';
import '../../services/like_service.dart';
import '../applications/apply/apply_screen.dart';
import 'offer_map.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final OfferService _offerService = OfferService();
  final LikeService _likeService = LikeService();

  late Future<List<Offer>> _offersFuture;

  final Set<String> _likedOfferIds = {};

  @override
  void initState() {
    super.initState();
    _loadOffers();
    _loadLikes();
  }

  void _loadOffers() {
    _offersFuture = _offerService.getOffers();
  }

  Future<void> _loadLikes() async {
    try {
      final likes = await _likeService.getMyLikes();

      if (!mounted) return;

      setState(() {
        _likedOfferIds
          ..clear()
          ..addAll(likes);
      });
    } catch (_) {
      // Si falla la consulta de likes,
      // dejamos las ofertas funcionando normalmente.
    }
  }

  Future<void> _refreshOffers() async {
    setState(() {
      _loadOffers();
    });

    await _offersFuture;
    await _loadLikes();
  }

  Future<void> _toggleLike(String offerId) async {
    final wasLiked = _likedOfferIds.contains(offerId);

    setState(() {
      if (wasLiked) {
        _likedOfferIds.remove(offerId);
      } else {
        _likedOfferIds.add(offerId);
      }
    });

    try {
      if (wasLiked) {
        await _likeService.unlikeOffer(offerId);
      } else {
        await _likeService.likeOffer(offerId);
      }
    } catch (e) {
      // Si la API falla, devolvemos el estado anterior.
      if (!mounted) return;

      setState(() {
        if (wasLiked) {
          _likedOfferIds.add(offerId);
        } else {
          _likedOfferIds.remove(offerId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar el like: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas'),
      ),
      body: FutureBuilder<List<Offer>>(
        future: _offersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: _refreshOffers,
            );
          }

          final offers = snapshot.data ?? [];

          if (offers.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshOffers,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text(
                      'No hay ofertas disponibles.',
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
            onRefresh: _refreshOffers,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];

                return _OfferCard(
                  offer: offer,
                  isLiked:
                  _likedOfferIds.contains(offer.id),
                  onLike: () => _toggleLike(offer.id),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OfferDetailScreen(
                          offer: offer,
                        ),
                      ),
                    );

                    // Actualizamos likes al volver.
                    _loadLikes();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _OfferCard({
    required this.offer,
    required this.isLiked,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              if (offer.photo != null &&
                  offer.photo!.isNotEmpty)
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12),
                  child: Image.network(
                    offer.photo!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return const SizedBox(
                        height: 180,
                        child: Center(
                          child: Icon(
                            Icons
                                .image_not_supported_outlined,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              if (offer.photo != null &&
                  offer.photo!.isNotEmpty)
                const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      offer.jobTypeName,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: onLike,
                    icon: Icon(
                      isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isLiked
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                offer.jobTypeName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                offer.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.work_outline,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contrato: ${offer.contractType}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${offer.payment.amount} '
                        '${offer.payment.currency} / '
                        '${offer.payment.period}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      offer.address,
                      style: const TextStyle(
                        color:
                        AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  child: const Text('Ver oferta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OfferDetailScreen extends StatefulWidget {
  final Offer offer;

  const OfferDetailScreen({
    super.key,
    required this.offer,
  });

  @override
  State<OfferDetailScreen> createState() =>
      _OfferDetailScreenState();
}

class _OfferDetailScreenState
    extends State<OfferDetailScreen> {
  final OfferService _offerService = OfferService();
  final LikeService _likeService = LikeService();

  late Future<Offer> _offerFuture;

  bool _isLiked = false;
  bool _likeLoading = false;

  @override
  void initState() {
    super.initState();

    _offerFuture =
        _offerService.getOfferById(widget.offer.id);

    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    try {
      final likes =
      await _likeService.getMyLikes();

      if (!mounted) return;

      setState(() {
        _isLiked =
            likes.contains(widget.offer.id);
      });
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    if (_likeLoading) return;

    final oldValue = _isLiked;

    setState(() {
      _isLiked = !oldValue;
      _likeLoading = true;
    });

    try {
      if (oldValue) {
        await _likeService.unlikeOffer(
          widget.offer.id,
        );
      } else {
        await _likeService.likeOffer(
          widget.offer.id,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLiked = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar el like: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _likeLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de oferta'),
        actions: [
          IconButton(
            onPressed:
            _likeLoading ? null : _toggleLike,
            icon: Icon(
              _isLiked
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
              _isLiked ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: FutureBuilder<Offer>(
        future: _offerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final offer =
              snapshot.data ?? widget.offer;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                if (offer.photo != null &&
                    offer.photo!.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(14),
                    child: Image.network(
                      offer.photo!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return const SizedBox(
                          height: 220,
                          child: Center(
                            child: Icon(
                              Icons
                                  .image_not_supported_outlined,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                Text(
                  offer.jobTypeName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  offer.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                _InfoRow(
                  icon: Icons.work_outline,
                  label: 'Tipo de contrato',
                  value: offer.contractType,
                ),

                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Pago',
                  value:
                  '${offer.payment.amount} '
                      '${offer.payment.currency} / '
                      '${offer.payment.period}',
                ),

                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Dirección',
                  value: offer.address,
                ),

                if (offer.deadline != null)
                  _InfoRow(
                    icon:
                    Icons.calendar_today_outlined,
                    label: 'Fecha límite',
                    value:
                    _formatDate(offer.deadline!),
                  ),

                const SizedBox(height: 20),

                OfferMap(
                  offer: offer,
                ),

                const SizedBox(height: 24),

                if (offer.questions.isNotEmpty) ...[
                  const Text(
                    'Preguntas de la oferta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...offer.questions.map(
                        (question) => Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color:
                          AppColors.secondary,
                        ),
                        title:
                        Text(question.label),
                        subtitle: Text(
                          question.required
                              ? 'Obligatoria'
                              : 'Opcional',
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result =
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ApplyScreen(
                                offer: offer,
                              ),
                        ),
                      );

                      if (result == true &&
                          context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Postulación enviada correctamente.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.send_outlined,
                    ),
                    label: const Text(
                      'Postularme a esta oferta',
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                    AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color:
                    AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}