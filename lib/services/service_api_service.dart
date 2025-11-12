import '../models/service_model.dart';
import '../services/api_client.dart';
import '../utils/app_logger.dart';

class ServiceApiService {
  static final ApiClient _apiClient = ApiClient();

  // Get all services (Public)
  static Future<List<Service>> getAllServices({
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? sortOrder,
    String? serviceType,
    String? rateType,
  }) async {
    try {
      AppLogger.apiRequest('GET', '/api/services');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (serviceType != null) 'serviceType': serviceType,
        if (rateType != null) 'rateType': rateType,
      };

      final response = await _apiClient.get(
        '/api/services',
        queryParameters: queryParams,
      );

      final List<dynamic> servicesJson = response.data['data'] ?? [];
      return servicesJson.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching services: $e');
      throw Exception('Failed to fetch services: $e');
    }
  }

  // Get service by ID (Public)
  static Future<Service> getServiceById(String id) async {
    try {
      AppLogger.apiRequest('GET', '/api/services/$id');
      
      final response = await _apiClient.get('/api/services/$id');
      return Service.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error fetching service: $e');
      throw Exception('Failed to fetch service: $e');
    }
  }

  // Create service (Auth required)
  static Future<Service> createService({
    required String postId,
    required String serviceType,
    required String rateType,
    double? hourlyRate,
    double? dailyRate,
    double? projectRate,
    String? currency,
    List<String>? skillsRequired,
    String? availability,
    String? portfolio,
    int? experience,
    List<String>? certifications,
  }) async {
    try {
      AppLogger.apiRequest('POST', '/api/services');
      
      final body = {
        'postId': postId,
        'serviceType': serviceType,
        'rateType': rateType,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        if (dailyRate != null) 'dailyRate': dailyRate,
        if (projectRate != null) 'projectRate': projectRate,
        'currency': currency ?? 'ETB',
        'skillsRequired': skillsRequired ?? [],
        if (availability != null) 'availability': availability,
        if (portfolio != null) 'portfolio': portfolio,
        'experience': experience ?? 0,
        'certifications': certifications ?? [],
      };

      final response = await _apiClient.post('/api/services', data: body);
      return Service.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error creating service: $e');
      throw Exception('Failed to create service: $e');
    }
  }

  // Update service (Auth required)
  static Future<Service> updateService(String id, Map<String, dynamic> updates) async {
    try {
      AppLogger.apiRequest('PUT', '/api/services/$id');
      
      final response = await _apiClient.put('/api/services/$id', data: updates);
      return Service.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error updating service: $e');
      throw Exception('Failed to update service: $e');
    }
  }

  // Delete service (Auth required)
  static Future<bool> deleteService(String id) async {
    try {
      AppLogger.apiRequest('DELETE', '/api/services/$id');
      
      await _apiClient.delete('/api/services/$id');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting service: $e');
      throw Exception('Failed to delete service: $e');
    }
  }
}
