import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/landing_api_config.dart';
import '../utils/app_logger.dart';

/// Landing Page Service
/// Handles all public API calls that don't require authentication
class LandingService extends ChangeNotifier {
  late final Dio _dio;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LandingService() {
    AppLogger.startup('Initializing Landing Service');
    
    _dio = Dio(BaseOptions(
      baseUrl: LandingApiConfig.apiUrl,
      connectTimeout: LandingApiConfig.connectionTimeout,
      receiveTimeout: LandingApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.apiRequest(
            options.method,
            options.path,
            data: options.data,
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final statusCode = response.statusCode ?? 0;
          final endpoint = response.requestOptions.path;
          final data = response.data;
          
          AppLogger.divider();
          AppLogger.success('✅ API RESPONSE: $statusCode');
          AppLogger.info('📍 Endpoint: $endpoint');
          AppLogger.info('🔢 Status Code: $statusCode');
          
          // Log response data structure
          if (data is Map) {
            AppLogger.info('📦 Response Type: Map');
            AppLogger.info('🔑 Keys: ${data.keys.join(", ")}');
            
            // Log success status if available
            if (data.containsKey('success')) {
              AppLogger.info('✓ Success: ${data['success']}');
            }
            
            // Log message if available
            if (data.containsKey('message')) {
              AppLogger.info('💬 Message: ${data['message']}');
            }
            
            // Log data count if it's a list
            if (data.containsKey('data')) {
              final responseData = data['data'];
              if (responseData is List) {
                AppLogger.info('📊 Data Count: ${responseData.length} items');
                AppLogger.info('📋 Sample: ${responseData.take(2).toList()}');
              } else if (responseData is Map) {
                AppLogger.info('📦 Data Keys: ${responseData.keys.join(", ")}');
                // Log pagination info if available
                if (responseData.containsKey('totalPages')) {
                  AppLogger.info('📄 Page ${responseData['currentPage'] ?? '?'} of ${responseData['totalPages'] ?? '?'}');
                }
                if (responseData.containsKey('posts')) {
                  AppLogger.info('📝 Posts Count: ${(responseData['posts'] as List).length}');
                } else if (responseData.containsKey('products')) {
                  AppLogger.info('🛍️ Products Count: ${(responseData['products'] as List).length}');
                } else if (responseData.containsKey('jobPosts')) {
                  AppLogger.info('💼 Job Posts Count: ${(responseData['jobPosts'] as List).length}');
                }
              } else {
                AppLogger.info('📦 Data: $responseData');
              }
            }
          } else if (data is List) {
            AppLogger.info('📦 Response Type: List');
            AppLogger.info('📊 Items Count: ${data.length}');
            AppLogger.info('📋 Sample: ${data.take(2).toList()}');
          } else {
            AppLogger.info('📦 Response: $data');
          }
          
          AppLogger.dividerBottom();
          return handler.next(response);
        },
        onError: (error, handler) {
          final statusCode = error.response?.statusCode;
          final endpoint = error.requestOptions.path;
          final errorData = error.response?.data;
          
          AppLogger.divider();
          AppLogger.error('🚨 LANDING API ERROR', tag: '');
          AppLogger.info('📍 Endpoint: $endpoint');
          if (statusCode != null) {
            AppLogger.info('🔢 Status Code: $statusCode');
          }
          
          if (errorData != null) {
            AppLogger.error('📦 Error Data: $errorData');
            if (errorData is Map && errorData.containsKey('message')) {
              AppLogger.error('💬 Error Message: ${errorData['message']}');
            }
          }
          AppLogger.dividerBottom();
          
          return handler.next(error);
        },
      ),
    );
  }

  // ==================== CATEGORIES ====================
  
  /// Get all categories
  Future<Map<String, dynamic>?> getAllCategories() async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/categories');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch categories', e);
      return null;
    }
  }

  /// Get category by ID
  Future<Map<String, dynamic>?> getCategoryById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/categories/$id');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch category', e);
      return null;
    }
  }

  // ==================== REGIONS ====================
  
  /// Get all regions
  Future<Map<String, dynamic>?> getAllRegions() async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/regions');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch regions', e);
      return null;
    }
  }

  /// Get region by ID
  Future<Map<String, dynamic>?> getRegionById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/regions/$id');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch region', e);
      return null;
    }
  }

  // ==================== CITIES ====================
  
  /// Get all cities
  Future<Map<String, dynamic>?> getAllCities() async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/cities');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch cities', e);
      return null;
    }
  }

  /// Get cities by region
  Future<Map<String, dynamic>?> getCitiesByRegion(String regionId) async {
    try {
      _setLoading(true);
      final response = await _dio.get(
        '/api/cities/region/$regionId',
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch cities by region', e);
      return null;
    }
  }

  /// Get city by ID
  Future<Map<String, dynamic>?> getCityById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/cities/$id');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch city', e);
      return null;
    }
  }

  // ==================== POSTS ====================
  
  /// Get all posts with optional filters
  Future<Map<String, dynamic>?> getAllPosts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? regionId,
    String? cityId,
    String? userId,
    String? postType,
    double? priceMin,
    double? priceMax,
    bool? isActive,
    String? search,
    String? startDate,
    String? endDate,
    bool? featured,
    bool? verified,
    bool? expiringSoon,
    bool? urgent,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
  }) async {
    try {
      _setLoading(true);
      final queryParams = LandingApiConfig.buildPostsQuery(
        page: page,
        limit: limit,
        categoryId: categoryId,
        regionId: regionId,
        cityId: cityId,
        userId: userId,
        postType: postType,
        priceMin: priceMin,
        priceMax: priceMax,
        isActive: isActive,
        search: search,
        startDate: startDate,
        endDate: endDate,
        featured: featured,
        verified: verified,
        expiringSoon: expiringSoon,
        urgent: urgent,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      
      final response = await _dio.get(
        '/api/posts',
        queryParameters: queryParams,
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch posts', e);
      return null;
    }
  }

  /// Get post by ID
  Future<Map<String, dynamic>?> getPostById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/posts/$id');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch post', e);
      return null;
    }
  }

  /// Get posts by category
  Future<Map<String, dynamic>?> getPostsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      final response = await _dio.get(
        '/api/posts/category/$categoryId',
        queryParameters: {'page': page, 'limit': limit},
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch posts by category', e);
      return null;
    }
  }

  /// Get posts by user
  Future<Map<String, dynamic>?> getPostsByUser(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      final response = await _dio.get(
        '/api/posts/user/$userId',
        queryParameters: {'page': page, 'limit': limit},
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch posts by user', e);
      return null;
    }
  }

  // ==================== PRODUCTS ====================
  
  /// Get all products with optional filters
  Future<Map<String, dynamic>?> getAllProducts({
    int page = 1,
    int limit = 10,
    String? condition,
    String? productCategory,
    bool? allowOffers,
    String? currency,
    int? stockQtyMin,
    int? stockQtyMax,
    String? categoryId,
    String? regionId,
    String? cityId,
    double? priceMin,
    double? priceMax,
    String? search,
  }) async {
    try {
      _setLoading(true);
      final queryParams = LandingApiConfig.buildProductsQuery(
        page: page,
        limit: limit,
        condition: condition,
        productCategory: productCategory,
        allowOffers: allowOffers,
        currency: currency,
        stockQtyMin: stockQtyMin,
        stockQtyMax: stockQtyMax,
        categoryId: categoryId,
        regionId: regionId,
        cityId: cityId,
        priceMin: priceMin,
        priceMax: priceMax,
        search: search,
      );
      
      final response = await _dio.get(
        '/api/products',
        queryParameters: queryParams,
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch products', e);
      return null;
    }
  }

  /// Get product by ID
  Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/products/$id');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch product', e);
      return null;
    }
  }

  // ==================== JOB POSTS ====================
  
  /// Get all job posts with optional filters
  Future<Map<String, dynamic>?> getAllJobPosts({
    int page = 1,
    int limit = 10,
    String? employmentType,
    String? experienceLevel,
    bool? remote,
    double? salaryMin,
    double? salaryMax,
    String? company,
    String? search,
  }) async {
    try {
      _setLoading(true);
      final queryParams = LandingApiConfig.buildJobPostsQuery(
        page: page,
        limit: limit,
        employmentType: employmentType,
        experienceLevel: experienceLevel,
        remote: remote,
        salaryMin: salaryMin,
        salaryMax: salaryMax,
        company: company,
        search: search,
      );
      
      final response = await _dio.get(
        '/api/job-posts',
        queryParameters: queryParams,
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch job posts', e);
      return null;
    }
  }

  /// Get job post by ID
  Future<Map<String, dynamic>?> getJobPostById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/job-posts/$id');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch job post', e);
      return null;
    }
  }

  // ==================== RENTAL LISTINGS ====================
  
  /// Get all rental listings with optional filters
  Future<Map<String, dynamic>?> getAllRentalListings({
    int page = 1,
    int limit = 10,
    String? propertyType,
    int? bedrooms,
    bool? furnished,
    double? minRent,
    double? maxRent,
  }) async {
    try {
      _setLoading(true);
      final queryParams = LandingApiConfig.buildRentalListingsQuery(
        page: page,
        limit: limit,
        propertyType: propertyType,
        bedrooms: bedrooms,
        furnished: furnished,
        minRent: minRent,
        maxRent: maxRent,
      );
      
      final response = await _dio.get(
        '/api/rental-listings',
        queryParameters: queryParams,
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch rental listings', e);
      return null;
    }
  }

  /// Get rental listing by ID
  Future<Map<String, dynamic>?> getRentalListingById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get(
        '/api/rental-listings/$id',
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch rental listing', e);
      return null;
    }
  }

  // ==================== SERVICES ====================
  
  /// Get all services with optional filters
  Future<Map<String, dynamic>?> getAllServices({
    int page = 1,
    int limit = 10,
    String? serviceType,
    double? minRate,
    double? maxRate,
  }) async {
    try {
      _setLoading(true);
      final queryParams = LandingApiConfig.buildServicesQuery(
        page: page,
        limit: limit,
        serviceType: serviceType,
        minRate: minRate,
        maxRate: maxRate,
      );
      
      final response = await _dio.get(
        '/api/services',
        queryParameters: queryParams,
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch services', e);
      return null;
    }
  }

  /// Get service by ID
  Future<Map<String, dynamic>?> getServiceById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get('/api/services/$id');
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch service', e);
      return null;
    }
  }

  // ==================== MATCHMAKING POSTS ====================
  
  /// Get all matchmaking posts with optional filters
  Future<Map<String, dynamic>?> getAllMatchmakingPosts({
    int page = 1,
    int limit = 10,
    String? visibility,
    String? religion,
  }) async {
    try {
      _setLoading(true);
      final queryParams = LandingApiConfig.buildMatchmakingPostsQuery(
        page: page,
        limit: limit,
        visibility: visibility,
        religion: religion,
      );
      
      final response = await _dio.get(
        '/api/matchmaking-posts',
        queryParameters: queryParams,
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch matchmaking posts', e);
      return null;
    }
  }

  /// Get matchmaking post by ID
  Future<Map<String, dynamic>?> getMatchmakingPostById(String id) async {
    try {
      _setLoading(true);
      final response = await _dio.get(
        '/api/matchmaking-posts/$id',
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Failed to fetch matchmaking post', e);
      return null;
    }
  }

  // ==================== SEARCH ====================
  
  /// Global search across all content types
  Future<Map<String, dynamic>?> globalSearch({
    required String query,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      final queryParams = LandingApiConfig.buildGlobalSearchQuery(
        query: query,
        type: type,
        page: page,
        limit: limit,
      );
      
      final response = await _dio.get(
        '/api/search/global',
        queryParameters: queryParams,
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Search failed', e);
      return null;
    }
  }

  /// Advanced search with filters
  Future<Map<String, dynamic>?> advancedSearch({
    required String query,
    String? categoryId,
    String? regionId,
    String? cityId,
    double? priceMin,
    double? priceMax,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      final queryParams = LandingApiConfig.buildAdvancedSearchQuery(
        query: query,
        categoryId: categoryId,
        regionId: regionId,
        cityId: cityId,
        priceMin: priceMin,
        priceMax: priceMax,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        limit: limit,
      );
      
      final response = await _dio.get(
        '/api/search/advanced',
        queryParameters: queryParams,
      );
      _setLoading(false);
      return response.data;
    } on DioException catch (e) {
      _handleError('Advanced search failed', e);
      return null;
    }
  }

  // ==================== HELPER METHODS ====================
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String message, DioException error) {
    _errorMessage = error.response?.data['message'] ?? message;
    AppLogger.error(message, error: error, tag: 'LANDING');
    _setLoading(false);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
