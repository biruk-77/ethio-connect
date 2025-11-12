import 'package:flutter/material.dart';
import '../../models/rental_listing_model.dart';
import '../../theme/app_colors.dart';

class RentalDetailScreen extends StatelessWidget {
  final RentalListing listing;

  const RentalDetailScreen({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.fullImageUrls.isNotEmpty) _buildImageGallery(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDetails(),
                  const SizedBox(height: 16),
                  if (listing.amenities.isNotEmpty) _buildAmenities(),
                  const SizedBox(height: 32),
                  _buildContactButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (listing.fullImageUrls.length == 1) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          listing.fullImageUrls.first,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.home, size: 64, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: listing.fullImageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            listing.fullImageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.home, size: 64, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.post?.title ?? 'Rental Property',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                listing.formattedPropertyType,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (listing.furnished)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'FURNISHED',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        if (listing.post?.price != null) ...[
          const SizedBox(height: 16),
          Text(
            '\$${listing.post!.price}/month',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Property Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Bedrooms', '${listing.bedrooms}'),
            _buildDetailRow('Bathrooms', '${listing.bathrooms}'),
            if (listing.squareFeet != null)
              _buildDetailRow('Square Feet', '${listing.squareFeet}'),
            _buildDetailRow('Furnished', listing.furnished ? 'Yes' : 'No'),
            _buildDetailRow('Pets Allowed', listing.petsAllowed ? 'Yes' : 'No'),
            if (listing.parkingSpaces != null)
              _buildDetailRow('Parking', listing.parkingSpaces!),
            if (listing.leaseDuration != null)
              _buildDetailRow('Lease Duration', listing.leaseDuration!),
            if (listing.securityDeposit != null)
              _buildDetailRow('Security Deposit', '\$${listing.securityDeposit}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amenities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: listing.amenities.map((amenity) => Chip(
                label: Text(amenity),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement inquiry functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact functionality coming soon!'),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Contact Landlord',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
