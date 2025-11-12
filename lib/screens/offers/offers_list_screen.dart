import 'package:flutter/material.dart';
import '../../models/offer_post_model.dart';
import '../../services/offer_post_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_logger.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/professional_app_bar.dart';
import 'offer_detail_screen.dart';
import 'create_offer_screen.dart';

class OffersListScreen extends StatefulWidget {
  const OffersListScreen({super.key});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  List<OfferPost> _offers = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOffers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadMoreOffers();
      }
    }
  }

  Future<void> _loadOffers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final offers = await OfferPostService.getAllOfferPosts(
        page: 1,
        limit: 10,
        sortBy: 'createdAt',
        sortOrder: 'DESC',
      );

      setState(() {
        _offers = offers;
        _currentPage = 1;
        _hasMore = offers.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading offers: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOffers() async {
    try {
      setState(() => _isLoading = true);

      final moreOffers = await OfferPostService.getAllOfferPosts(
        page: _currentPage + 1,
        limit: 10,
        sortBy: 'createdAt',
        sortOrder: 'DESC',
      );

      setState(() {
        _offers.addAll(moreOffers);
        _currentPage++;
        _hasMore = moreOffers.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading more offers: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToCreateOffer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOfferScreen(),
      ),
    ).then((_) => _loadOffers());
  }

  void _navigateToOfferDetail(OfferPost offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailScreen(offer: offer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfessionalAppBar(
        title: 'Special Offers',
        showSearch: true,
        showNotifications: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _navigateToCreateOffer,
            tooltip: 'Create Offer',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
            },
            tooltip: 'Filter Offers',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _offers.isEmpty) {
      return const LoadingWidget();
    }

    if (_error != null && _offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load offers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOffers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_offers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No offers available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _offers.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _offers.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: const Center(child: LoadingWidget()),
            );
          }

          return _buildOfferCard(_offers[index]);
        },
      ),
    );
  }

  Widget _buildOfferCard(OfferPost offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToOfferDetail(offer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.post?.title ?? 'Offer',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.offerType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!offer.isValid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'EXPIRED',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '\$${offer.originalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${(offer.discountedPrice ?? (offer.originalPrice * (1 - (offer.discountPercentage ?? 0) / 100))).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  if (offer.discountPercentage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${offer.discountPercentage!.round()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Valid until ${offer.validUntil.day}/${offer.validUntil.month}/${offer.validUntil.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (offer.maxRedemptions > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${offer.remainingRedemptions} redemptions left',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
