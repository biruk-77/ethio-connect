import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../models/verification_model.dart';
import '../utils/app_logger.dart';
import '../utils/category_verification_map.dart';
import 'post_api_client.dart';
import 'verification_service.dart';

class PostService {
  final PostApiClient _apiClient = PostApiClient();
  final VerificationService _verificationService = VerificationService();

  /// Check if user can post in a specific category
  /// Returns VerificationCheckResult with details about verification status
  /// Call this before attempting to create a post for better UX
  Future<VerificationCheckResult?> checkCategoryAccess(String category) async {
    AppLogger.info('🔍 Checking access for category: $category');
    
    // Get required verification type for this category
    final verificationType = CategoryVerificationMap.getVerificationTypeForCategory(category);
    
    if (verificationType == null) {
      AppLogger.warning('⚠️ Category "$category" not found in verification map');
      // Category doesn't require verification, allow posting
      return VerificationCheckResult(
        userId: '',
        type: 'none',
        hasRole: true,
        hasVerification: true,
        isVerified: true,
        roleName: 'user',
        reason: 'This category does not require special verification',
      );
    }

    AppLogger.document('Category "$category" requires ${verificationType.apiValue} verification');
    
    // Check if user has the required verification
    final result = await _verificationService.isVerified(verificationType);
    
    return result;
  }

  // Get all posts/products
  Future<List<Post>> getPosts({
    String? categoryId,
    String? postType,
    String? regionId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('📦 Fetching posts...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (postType != null) queryParams['postType'] = postType;
      if (regionId != null) queryParams['regionId'] = regionId;

      final response = await _apiClient.get(
        '/api/posts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> posts = response.data['data']['posts'] ?? [];
        final result = posts.map((p) => Post.fromJson(p)).toList();
        AppLogger.success('✅ Found ${result.length} posts');
        return result;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch posts: ${e.message}');
      return [];
    }
  }

  // Get products specifically
  Future<List<Product>> getProducts({
    String? categoryId,
    String? regionId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('🛍️ Fetching products...');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (regionId != null) queryParams['regionId'] = regionId;

      final response = await _apiClient.get(
        '/api/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> products = response.data['data']['products'] ?? [];
        final result = products.map((p) => Product.fromJson(p)).toList();
        AppLogger.success('✅ Found ${result.length} products');
        return result;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch products: ${e.message}');
      return [];
    }
  }

  // Get single post by ID
  Future<Post?> getPostById(String postId) async {
    try {
      AppLogger.info('📄 Fetching post: $postId');

      final response = await _apiClient.get('/api/posts/$postId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final postData = response.data['data']['post'];
        AppLogger.success('✅ Post fetched');
        return Post.fromJson(postData);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch post: ${e.message}');
      return null;
    }
  }

  // Get single product by post ID
  Future<Product?> getProductByPostId(String postId) async {
    try {
      AppLogger.info('🛍️ Fetching product: $postId');

      final response = await _apiClient.get('/api/products/$postId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final productData = response.data['data']['product'];
        AppLogger.success('✅ Product fetched');
        return Product.fromJson(productData);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch product: ${e.message}');
      return null;
    }
  }

  // Get user's posts
  Future<List<Post>> getMyPosts() async {
    try {
      AppLogger.info('📦 Fetching my posts...');

      final response = await _apiClient.get('/api/posts/my');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> posts = response.data['data']['posts'] ?? [];
        final result = posts.map((p) => Post.fromJson(p)).toList();
        AppLogger.success('✅ Found ${result.length} of my posts');
        return result;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch my posts: ${e.message}');
      return [];
    }
  }

  // Search posts
  Future<List<Post>> searchPosts({
    required String query,
    String? categoryId,
    String? regionId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('🔍 Searching posts: $query');

      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (regionId != null) queryParams['regionId'] = regionId;

      final response = await _apiClient.get(
        '/api/posts/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> posts = response.data['data']['posts'] ?? [];
        final result = posts.map((p) => Post.fromJson(p)).toList();
        AppLogger.success('✅ Found ${result.length} posts');
        return result;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to search posts: ${e.message}');
      return [];
    }
  }

  // Create a new post
  /// Throws DioException with details if verification is required
  /// Check response status 403 for verification errors
  Future<Post?> createPost({
    required String categoryId,
    required String postType,
    required String title,
    required String description,
    double? price,
    String? regionId,
    String? cityId,
    List<String>? tags,
    bool? isActive,
    String? expiresAt,
  }) async {
    try {
      AppLogger.info('📝 Creating new post...');

      final data = {
        'categoryId': categoryId,
        'postType': postType,
        'title': title,
        'description': description,
        if (price != null) 'price': price,
        if (regionId != null) 'regionId': regionId,
        if (cityId != null) 'cityId': cityId,
        if (tags != null) 'tags': tags,
        if (isActive != null) 'isActive': isActive,
        if (expiresAt != null) 'expiresAt': expiresAt,
      };

      final response = await _apiClient.post('/api/posts', data: data);

      if (response.statusCode == 201 && response.data['success'] == true) {
        final postData = response.data['data']['post'];
        AppLogger.success('✅ Post created successfully');
        return Post.fromJson(postData);
      }

      return null;
    } on DioException catch (e) {
      // Handle verification errors (403 Forbidden)
      if (e.response?.statusCode == 403) {
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'You are not verified to post in this category';
        final details = errorData?['details'];
        
        AppLogger.error('❌ Verification required: $message');
        if (details != null) {
          AppLogger.warning('Required: ${details['requiredVerification']}');
          AppLogger.warning('Reason: ${details['reason']}');
          AppLogger.info('Action: ${details['action']}');
        }
        
        // Re-throw with detailed error for UI to handle
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: message,
        );
      }
      
      AppLogger.error('Failed to create post: ${e.message}');
      rethrow;
    }
  }

  // Update post
  Future<Post?> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      AppLogger.info('📝 Updating post: $postId');

      final response = await _apiClient.put(
        '/api/posts/$postId',
        data: updates,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final postData = response.data['data']['post'];
        AppLogger.success('✅ Post updated successfully');
        return Post.fromJson(postData);
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('Failed to update post: ${e.message}');
      return null;
    }
  }

  // Delete post
  Future<bool> deletePost(String postId) async {
    try {
      AppLogger.info('🗑️ Deleting post: $postId');

      final response = await _apiClient.delete('/api/posts/$postId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.success('✅ Post deleted successfully');
        return true;
      }

      return false;
    } on DioException catch (e) {
      AppLogger.error('Failed to delete post: ${e.message}');
      return false;
    }
  }

  // Get posts by category
  Future<List<Post>> getPostsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('📦 Fetching posts for category: $categoryId');

      final response = await _apiClient.get(
        '/api/posts/category/$categoryId',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> posts = response.data['data']['posts'] ?? [];
        final result = posts.map((p) => Post.fromJson(p)).toList();
        AppLogger.success('✅ Found ${result.length} posts');
        return result;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch posts by category: ${e.message}');
      return [];
    }
  }

  // Get posts by user
  Future<List<Post>> getPostsByUser(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('📦 Fetching posts for user: $userId');

      final response = await _apiClient.get(
        '/api/posts/user/$userId',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> posts = response.data['data']['posts'] ?? [];
        final result = posts.map((p) => Post.fromJson(p)).toList();
        AppLogger.success('✅ Found ${result.length} posts');
        return result;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch posts by user: ${e.message}');
      return [];
    }
  }

  // Global search
  Future<Map<String, dynamic>> globalSearch({
    required String query,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('🔍 Global search: $query');

      final queryParams = {
        'q': query,
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      };

      final response = await _apiClient.get(
        '/api/search/global',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.success('✅ Search completed');
        return response.data['data'];
      }

      return {};
    } on DioException catch (e) {
      AppLogger.error('Failed to perform global search: ${e.message}');
      return {};
    }
  }

  // Advanced search with filters
  Future<List<Post>> advancedSearch({
    required String query,
    String? categoryId,
    String? regionId,
    String? cityId,
    double? priceMin,
    double? priceMax,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('🔍 Advanced search: $query');

      final queryParams = {
        'q': query,
        'page': page,
        'limit': limit,
        if (categoryId != null) 'categoryId': categoryId,
        if (regionId != null) 'regionId': regionId,
        if (cityId != null) 'cityId': cityId,
        if (priceMin != null) 'priceMin': priceMin,
        if (priceMax != null) 'priceMax': priceMax,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };

      final response = await _apiClient.get(
        '/api/search/advanced',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> posts = response.data['data']['posts'] ?? [];
        final result = posts.map((p) => Post.fromJson(p)).toList();
        AppLogger.success('✅ Found ${result.length} posts');
        return result;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to perform advanced search: ${e.message}');
      return [];
    }
  }

  // Get job posts
  Future<List<dynamic>> getJobPosts({
    String? employmentType,
    String? experienceLevel,
    bool? remote,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('💼 Fetching job posts...');

      final queryParams = {
        'page': page,
        'limit': limit,
        if (employmentType != null) 'employmentType': employmentType,
        if (experienceLevel != null) 'experienceLevel': experienceLevel,
        if (remote != null) 'remote': remote,
      };

      final response = await _apiClient.get(
        '/api/job-posts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> jobs = response.data['data']['jobPosts'] ?? [];
        AppLogger.success('✅ Found ${jobs.length} job posts');
        return jobs;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch job posts: ${e.message}');
      return [];
    }
  }

  // Get categories
  Future<List<dynamic>> getCategories() async {
    try {
      AppLogger.info('📂 Fetching categories...');

      final response = await _apiClient.get('/api/categories');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> categories = response.data['data']['categories'] ?? [];
        AppLogger.success('✅ Found ${categories.length} categories');
        return categories;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch categories: ${e.message}');
      return [];
    }
  }

  // Get regions
  Future<List<dynamic>> getRegions() async {
    try {
      AppLogger.info('🗺️ Fetching regions...');

      final response = await _apiClient.get('/api/regions');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> regions = response.data['data']['regions'] ?? [];
        AppLogger.success('✅ Found ${regions.length} regions');
        return regions;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch regions: ${e.message}');
      return [];
    }
  }

  // Get cities by region
  Future<List<dynamic>> getCitiesByRegion(String regionId) async {
    try {
      AppLogger.info('🏙️ Fetching cities for region: $regionId');

      final response = await _apiClient.get('/api/cities?regionId=$regionId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> cities = response.data['data']['cities'] ?? [];
        AppLogger.success('✅ Found ${cities.length} cities');
        return cities;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch cities: ${e.message}');
      return [];
    }
  }

  // Get services
  Future<List<dynamic>> getServices({
    String? serviceType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('🔧 Fetching services...');

      final queryParams = {
        'page': page,
        'limit': limit,
        if (serviceType != null) 'serviceType': serviceType,
      };

      final response = await _apiClient.get(
        '/api/services',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> services = response.data['data']['services'] ?? [];
        AppLogger.success('✅ Found ${services.length} services');
        return services;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch services: ${e.message}');
      return [];
    }
  }

  // Get rental listings
  Future<List<dynamic>> getRentalListings({
    String? propertyType,
    int? bedrooms,
    bool? furnished,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('🏠 Fetching rental listings...');

      final queryParams = {
        'page': page,
        'limit': limit,
        if (propertyType != null) 'propertyType': propertyType,
        if (bedrooms != null) 'bedrooms': bedrooms,
        if (furnished != null) 'furnished': furnished,
      };

      final response = await _apiClient.get(
        '/api/rental-listings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> rentals = response.data['data']['rentalListings'] ?? [];
        AppLogger.success('✅ Found ${rentals.length} rental listings');
        return rentals;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch rental listings: ${e.message}');
      return [];
    }
  }

  // Get matchmaking posts
  Future<List<dynamic>> getMatchmakingPosts({
    String? visibility,
    String? religion,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('💑 Fetching matchmaking posts...');

      final queryParams = {
        'page': page,
        'limit': limit,
        if (visibility != null) 'visibility': visibility,
        if (religion != null) 'religion': religion,
      };

      final response = await _apiClient.get(
        '/api/matchmaking-posts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> posts = response.data['data']['matchmakingPosts'] ?? [];
        AppLogger.success('✅ Found ${posts.length} matchmaking posts');
        return posts;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch matchmaking posts: ${e.message}');
      return [];
    }
  }
}
