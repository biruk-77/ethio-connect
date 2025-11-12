import 'package:flutter/material.dart';
import '../../models/rental_listing_model.dart';
import '../../services/rental_listing_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_logger.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/professional_app_bar.dart';
import 'rental_detail_screen.dart';
import 'create_rental_screen.dart';

class RentalListingsScreen extends StatefulWidget {
  const RentalListingsScreen({super.key});

  @override
  State<RentalListingsScreen> createState() => _RentalListingsScreenState();
}

class _RentalListingsScreenState extends State<RentalListingsScreen> {
  List<RentalListing> _listings = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Filters
  String? _selectedPropertyType;
  int? _minBedrooms;
  bool? _furnishedFilter;

  @override
  void initState() {
    super.initState();
    _loadListings();
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
        _loadMoreListings();
      }
    }
  }

  Future<void> _loadListings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final listings = await RentalListingService.getAllRentalListings(
        page: 1,
        limit: 10,
        propertyType: _selectedPropertyType,
        minBedrooms: _minBedrooms,
        furnished: _furnishedFilter,
      );

      setState(() {
        _listings = listings;
        _currentPage = 1;
        _hasMore = listings.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading rental listings: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreListings() async {
    try {
      setState(() => _isLoading = true);

      final moreListings = await RentalListingService.getAllRentalListings(
        page: _currentPage + 1,
        limit: 10,
        propertyType: _selectedPropertyType,
        minBedrooms: _minBedrooms,
        furnished: _furnishedFilter,
      );

      setState(() {
        _listings.addAll(moreListings);
        _currentPage++;
        _hasMore = moreListings.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading more listings: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Listings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPropertyType,
              decoration: const InputDecoration(labelText: 'Property Type'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Types')),
                DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                DropdownMenuItem(value: 'house', child: Text('House')),
                DropdownMenuItem(value: 'condo', child: Text('Condo')),
                DropdownMenuItem(value: 'studio', child: Text('Studio')),
              ],
              onChanged: (value) => _selectedPropertyType = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _minBedrooms,
              decoration: const InputDecoration(labelText: 'Min Bedrooms'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Any')),
                DropdownMenuItem(value: 1, child: Text('1+')),
                DropdownMenuItem(value: 2, child: Text('2+')),
                DropdownMenuItem(value: 3, child: Text('3+')),
                DropdownMenuItem(value: 4, child: Text('4+')),
              ],
              onChanged: (value) => _minBedrooms = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<bool>(
              value: _furnishedFilter,
              decoration: const InputDecoration(labelText: 'Furnished'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Any')),
                DropdownMenuItem(value: true, child: Text('Furnished')),
                DropdownMenuItem(value: false, child: Text('Unfurnished')),
              ],
              onChanged: (value) => _furnishedFilter = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _selectedPropertyType = null;
              _minBedrooms = null;
              _furnishedFilter = null;
              Navigator.pop(context);
              _loadListings();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadListings();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateRental() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRentalScreen(),
      ),
    ).then((_) => _loadListings());
  }

  void _navigateToRentalDetail(RentalListing listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RentalDetailScreen(listing: listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfessionalAppBar(
        title: 'Rental Properties',
        showSearch: true,
        showNotifications: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Properties',
          ),
          IconButton(
            icon: const Icon(Icons.add_home),
            onPressed: _navigateToCreateRental,
            tooltip: 'List Property',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _listings.isEmpty) {
      return const LoadingWidget();
    }

    if (_error != null && _listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load listings',
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
              onPressed: _loadListings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_listings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No rental listings available',
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
      onRefresh: _loadListings,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _listings.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _listings.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget()),
            );
          }

          return _buildListingCard(_listings[index]);
        },
      ),
    );
  }

  Widget _buildListingCard(RentalListing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToRentalDetail(listing),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.firstImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    listing.firstImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.home, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.post?.title ?? 'Rental Property',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!listing.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NOT AVAILABLE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          listing.formattedPropertyType,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (listing.furnished)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'FURNISHED',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.bedroomBathroomText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (listing.squareFeet != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${listing.squareFeet} sq ft',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (listing.post?.price != null)
                    Text(
                      '\$${listing.post!.price}/month',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  if (listing.amenities.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: listing.amenities.take(3).map((amenity) => 
                        Chip(
                          label: Text(
                            amenity,
                            style: const TextStyle(fontSize: 10),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
