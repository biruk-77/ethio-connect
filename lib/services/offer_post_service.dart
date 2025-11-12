import '../models/offer_post_model.dart';
import '../services/api_client.dart';
import '../utils/app_logger.dart';

class OfferPostService {
  static final ApiClient _apiClient = ApiClient();

  // Get all offer posts (Public)
  static Future<List<OfferPost>> getAllOfferPosts({
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? sortOrder,
    String? offerType,
    bool? isActive,
    double? minDiscount,
  }) async {
    try {
      AppLogger.apiRequest('GET', '/api/offer-posts');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (offerType != null) 'offerType': offerType,
        if (isActive != null) 'isActive': isActive,
        if (minDiscount != null) 'minDiscount': minDiscount,
      };

      final response = await _apiClient.get(
        '/api/offer-posts',
        queryParameters: queryParams,
      );

      final List<dynamic> offerPostsJson = response.data['data'] ?? [];
      return offerPostsJson.map((json) => OfferPost.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching offer posts: $e');
      throw Exception('Failed to fetch offer posts: $e');
    }
  }

  // Get offer post by ID (Public)
  static Future<OfferPost> getOfferPostById(String id) async {
    try {
      AppLogger.apiRequest('GET', '/api/offer-posts/$id');
      
      final response = await _apiClient.get('/api/offer-posts/$id');
      return OfferPost.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error fetching offer post: $e');
      throw Exception('Failed to fetch offer post: $e');
    }
  }

  // Create offer post (Auth required)
  static Future<OfferPost> createOfferPost({
    required String postId,
    required String offerType,
    required double originalPrice,
    double? discountedPrice,
    double? discountPercentage,
    required DateTime validFrom,
    required DateTime validUntil,
    String? termsAndConditions,
    required int maxRedemptions,
  }) async {
    try {
      AppLogger.apiRequest('POST', '/api/offer-posts');
      
      final body = {
        'postId': postId,
        'offerType': offerType,
        'originalPrice': originalPrice,
        if (discountedPrice != null) 'discountedPrice': discountedPrice,
        if (discountPercentage != null) 'discountPercentage': discountPercentage,
        'validFrom': validFrom.toIso8601String(),
        'validUntil': validUntil.toIso8601String(),
        if (termsAndConditions != null) 'termsAndConditions': termsAndConditions,
        'maxRedemptions': maxRedemptions,
        'redemptionCount': 0,
      };

      final response = await _apiClient.post('/api/offer-posts', data: body);
      return OfferPost.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error creating offer post: $e');
      throw Exception('Failed to create offer post: $e');
    }
  }

  // Update offer post (Auth required)
  static Future<OfferPost> updateOfferPost(String id, Map<String, dynamic> updates) async {
    try {
      AppLogger.apiRequest('PUT', '/api/offer-posts/$id');
      
      final response = await _apiClient.put('/api/offer-posts/$id', data: updates);
      return OfferPost.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error updating offer post: $e');
      throw Exception('Failed to update offer post: $e');
    }
  }

  // Delete offer post (Auth required)
  static Future<bool> deleteOfferPost(String id) async {
    try {
      AppLogger.apiRequest('DELETE', '/api/offer-posts/$id');
      
      await _apiClient.delete('/api/offer-posts/$id');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting offer post: $e');
      throw Exception('Failed to delete offer post: $e');
    }
  }

  // Redeem offer (Auth required)
  static Future<bool> redeemOffer(String id) async {
    try {
      AppLogger.apiRequest('POST', '/api/offer-posts/$id/redeem');
      
      await _apiClient.post('/api/offer-posts/$id/redeem');
      return true;
    } catch (e) {
      AppLogger.error('Error redeeming offer: $e');
      throw Exception('Failed to redeem offer: $e');
    }
  }
}
