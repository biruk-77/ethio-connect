import '../models/rental_listing_model.dart';
import '../services/api_client.dart';
import '../utils/app_logger.dart';

class RentalListingService {
  static final ApiClient _apiClient = ApiClient();

  // Get all rental listings (Public)
  static Future<List<RentalListing>> getAllRentalListings({
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? propertyType,
    int? minBedrooms,
    bool? furnished,
  }) async {
    try {
      AppLogger.apiRequest('GET', '/api/rental-listings');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (sortBy != null) 'sortBy': sortBy,
        if (propertyType != null) 'propertyType': propertyType,
        if (minBedrooms != null) 'minBedrooms': minBedrooms,
        if (furnished != null) 'furnished': furnished,
      };

      final response = await _apiClient.get(
        '/api/rental-listings',
        queryParameters: queryParams,
      );

      final List<dynamic> listingsJson = response.data['data'] ?? [];
      return listingsJson.map((json) => RentalListing.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching rental listings: $e');
      throw Exception('Failed to fetch rental listings: $e');
    }
  }

  // Get rental listing by ID (Public)
  static Future<RentalListing> getRentalListingById(String id) async {
    try {
      AppLogger.apiRequest('GET', '/api/rental-listings/$id');
      
      final response = await _apiClient.get('/api/rental-listings/$id');
      return RentalListing.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error fetching rental listing: $e');
      throw Exception('Failed to fetch rental listing: $e');
    }
  }

  // Create rental listing (Auth required)
  static Future<RentalListing> createRentalListing({
    required String postId,
    required String propertyType,
    required int bedrooms,
    required int bathrooms,
    int? squareFeet,
    bool? furnished,
    List<String>? amenities,
    double? securityDeposit,
    String? leaseDuration,
    bool? petsAllowed,
    String? parkingSpaces,
    List<String>? photos,
    Map<String, dynamic>? coordinates,
    DateTime? availableFrom,
  }) async {
    try {
      AppLogger.apiRequest('POST', '/api/rental-listings');
      
      final body = {
        'postId': postId,
        'propertyType': propertyType,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        if (squareFeet != null) 'squareFeet': squareFeet,
        'furnished': furnished ?? false,
        'amenities': amenities ?? [],
        if (securityDeposit != null) 'securityDeposit': securityDeposit,
        if (leaseDuration != null) 'leaseDuration': leaseDuration,
        'petsAllowed': petsAllowed ?? false,
        if (parkingSpaces != null) 'parkingSpaces': parkingSpaces,
        'photos': photos ?? [],
        if (coordinates != null) 'coordinates': coordinates,
        if (availableFrom != null) 'availableFrom': availableFrom.toIso8601String(),
      };

      final response = await _apiClient.post('/api/rental-listings', data: body);
      return RentalListing.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error creating rental listing: $e');
      throw Exception('Failed to create rental listing: $e');
    }
  }

  // Update rental listing (Auth required)
  static Future<RentalListing> updateRentalListing(String id, Map<String, dynamic> updates) async {
    try {
      AppLogger.apiRequest('PUT', '/api/rental-listings/$id');
      
      final response = await _apiClient.put('/api/rental-listings/$id', data: updates);
      return RentalListing.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error updating rental listing: $e');
      throw Exception('Failed to update rental listing: $e');
    }
  }

  // Delete rental listing (Auth required)
  static Future<bool> deleteRentalListing(String id) async {
    try {
      AppLogger.apiRequest('DELETE', '/api/rental-listings/$id');
      
      await _apiClient.delete('/api/rental-listings/$id');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting rental listing: $e');
      throw Exception('Failed to delete rental listing: $e');
    }
  }
}
