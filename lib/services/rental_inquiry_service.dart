import '../models/rental_inquiry_model.dart';
import '../services/api_client.dart';
import '../utils/app_logger.dart';

class RentalInquiryService {
  static final ApiClient _apiClient = ApiClient();

  // Get all rental inquiries (Auth required)
  static Future<List<RentalInquiry>> getAllRentalInquiries({
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? status,
  }) async {
    try {
      AppLogger.apiRequest('GET', '/api/rental-inquiries');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (sortBy != null) 'sortBy': sortBy,
        if (status != null) 'status': status,
      };

      final response = await _apiClient.get(
        '/api/rental-inquiries',
        queryParameters: queryParams,
      );

      final List<dynamic> inquiriesJson = response.data['data'] ?? [];
      return inquiriesJson.map((json) => RentalInquiry.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching rental inquiries: $e');
      throw Exception('Failed to fetch rental inquiries: $e');
    }
  }

  // Get rental inquiry by ID (Auth required)
  static Future<RentalInquiry> getRentalInquiryById(String id) async {
    try {
      AppLogger.apiRequest('GET', '/api/rental-inquiries/$id');
      
      final response = await _apiClient.get('/api/rental-inquiries/$id');
      return RentalInquiry.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error fetching rental inquiry: $e');
      throw Exception('Failed to fetch rental inquiry: $e');
    }
  }

  // Get rental inquiries by post ID (Auth required)
  static Future<List<RentalInquiry>> getRentalInquiriesByPost(String postId) async {
    try {
      AppLogger.apiRequest('GET', '/api/rental-inquiries/post/$postId');
      
      final response = await _apiClient.get('/api/rental-inquiries/post/$postId');
      final List<dynamic> inquiriesJson = response.data['data'] ?? [];
      return inquiriesJson.map((json) => RentalInquiry.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching rental inquiries by post: $e');
      throw Exception('Failed to fetch rental inquiries by post: $e');
    }
  }

  // Get rental inquiries by tenant ID (Auth required)
  static Future<List<RentalInquiry>> getRentalInquiriesByTenant(String tenantId) async {
    try {
      AppLogger.apiRequest('GET', '/api/rental-inquiries/tenant/$tenantId');
      
      final response = await _apiClient.get('/api/rental-inquiries/tenant/$tenantId');
      final List<dynamic> inquiriesJson = response.data['data'] ?? [];
      return inquiriesJson.map((json) => RentalInquiry.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching rental inquiries by tenant: $e');
      throw Exception('Failed to fetch rental inquiries by tenant: $e');
    }
  }

  // Create rental inquiry (Auth required)
  static Future<RentalInquiry> createRentalInquiry({
    required String postId,
    required String tenantId,
    required String message,
    required DateTime moveInDate,
    required int leaseDuration,
  }) async {
    try {
      AppLogger.apiRequest('POST', '/api/rental-inquiries');
      
      final body = {
        'postId': postId,
        'tenantId': tenantId,
        'message': message,
        'moveInDate': moveInDate.toIso8601String(),
        'leaseDuration': leaseDuration,
      };

      final response = await _apiClient.post('/api/rental-inquiries', data: body);
      return RentalInquiry.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error creating rental inquiry: $e');
      throw Exception('Failed to create rental inquiry: $e');
    }
  }

  // Update rental inquiry (Auth required)
  static Future<RentalInquiry> updateRentalInquiry(String id, Map<String, dynamic> updates) async {
    try {
      AppLogger.apiRequest('PUT', '/api/rental-inquiries/$id');
      
      final response = await _apiClient.put('/api/rental-inquiries/$id', data: updates);
      return RentalInquiry.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error updating rental inquiry: $e');
      throw Exception('Failed to update rental inquiry: $e');
    }
  }

  // Delete rental inquiry (Auth required)
  static Future<bool> deleteRentalInquiry(String id) async {
    try {
      AppLogger.apiRequest('DELETE', '/api/rental-inquiries/$id');
      
      await _apiClient.delete('/api/rental-inquiries/$id');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting rental inquiry: $e');
      throw Exception('Failed to delete rental inquiry: $e');
    }
  }
}
