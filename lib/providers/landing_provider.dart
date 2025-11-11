import 'package:flutter/foundation.dart';
import '../services/landing_service.dart';
import '../utils/app_logger.dart';

/// Landing Provider
/// Manages state and data for the landing page
class LandingProvider extends ChangeNotifier {
  final LandingService _landingService = LandingService();

  // State variables
  List<dynamic> _categories = [];
  Map<String, dynamic>? _categoryDetails;
  List<dynamic> _regions = [];
  List<dynamic> _cities = [];
  List<dynamic> _posts = [];
  List<dynamic> _products = [];
  List<dynamic> _jobPosts = [];
  List<dynamic> _rentalListings = [];
  List<dynamic> _services = [];
  List<dynamic> _matchmakingPosts = [];
  List<dynamic> _searchResults = [];

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // Loading states
  bool _isLoadingCategories = false;
  bool _isLoadingCategoryDetails = false;
  bool _isLoadingRegions = false;
  bool _isLoadingCities = false;
  bool _isLoadingPosts = false;
  bool _isLoadingProducts = false;
  bool _isLoadingJobPosts = false;
  bool _isLoadingRentals = false;
  bool _isLoadingServices = false;
  bool _isLoadingMatchmaking = false;
  bool _isSearching = false;

  String? _errorMessage;

  // Getters
  List<dynamic> get categories => _categories;
  Map<String, dynamic>? get categoryDetails => _categoryDetails;
  List<dynamic> get regions => _regions;
  List<dynamic> get cities => _cities;
  List<dynamic> get posts => _posts;
  List<dynamic> get products => _products;
  List<dynamic> get jobPosts => _jobPosts;
  List<dynamic> get rentalListings => _rentalListings;
  List<dynamic> get services => _services;
  List<dynamic> get matchmakingPosts => _matchmakingPosts;
  List<dynamic> get searchResults => _searchResults;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;

  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingCategoryDetails => _isLoadingCategoryDetails;
  bool get isLoadingRegions => _isLoadingRegions;
  bool get isLoadingCities => _isLoadingCities;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingJobPosts => _isLoadingJobPosts;
  bool get isLoadingRentals => _isLoadingRentals;
  bool get isLoadingServices => _isLoadingServices;
  bool get isLoadingMatchmaking => _isLoadingMatchmaking;
  bool get isSearching => _isSearching;

  String? get errorMessage => _errorMessage;

  // ==================== CATEGORIES ====================

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getAllCategories();
    
    if (response != null && response['success'] == true) {
      final data = response['data'];
      
      // Log raw API response
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.info('📦 RAW CATEGORIES API RESPONSE:');
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.info('Data Type: ${data.runtimeType}');
      AppLogger.info('Data Keys: ${data is Map ? data.keys.toList() : "Not a Map"}');
      
      if (data is Map && data['categories'] != null) {
        final categories = data['categories'];
        AppLogger.info('Categories Count: ${categories.length}');
        AppLogger.info('');
        
        for (var i = 0; i < categories.length; i++) {
          final cat = categories[i];
          AppLogger.info('🔹 Category ${i + 1}:');
          AppLogger.info('   🆔 ID: ${cat['id']}');
          AppLogger.info('   📛 Name: ${cat['categoryName']}');
          AppLogger.info('   📝 Description: ${cat['description']}');
          AppLogger.info('   📊 Post Count: ${cat['postCount']}');
          AppLogger.info('');
        }
        
        _categories = categories;
      } else {
        _categories = data ?? [];
      }
      
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.info('✅ STORED CATEGORIES IN PROVIDER:');
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.info('Total categories stored: ${_categories.length}');
      for (var i = 0; i < _categories.length; i++) {
        final cat = _categories[i];
        AppLogger.info('${i + 1}. ${cat['categoryName']} (ID: ${cat['id']}) - ${cat['postCount']} posts');
      }
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } else {
      _errorMessage = 'Failed to load categories';
    }

    _isLoadingCategories = false;
    notifyListeners();
  }

  /// Fetch category details by ID with posts
  Future<void> fetchCategoryDetails(String categoryId) async {
    _isLoadingCategoryDetails = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getCategoryById(categoryId);
    
    if (response != null && response['success'] == true) {
      _categoryDetails = response['data'];
      AppLogger.success('Loaded category details: ${_categoryDetails?['categoryName']}');
      AppLogger.info('Posts in category: ${(_categoryDetails?['posts'] as List?)?.length ?? 0}');
    } else {
      _errorMessage = 'Failed to load category details';
      _categoryDetails = null;
    }

    _isLoadingCategoryDetails = false;
    notifyListeners();
  }

  /// Clear category details
  void clearCategoryDetails() {
    _categoryDetails = null;
    notifyListeners();
  }

  /// Fetch post details by ID
  Future<Map<String, dynamic>?> fetchPostDetails(String postId) async {
    try {
      AppLogger.info('Fetching post details for ID: $postId');
      final response = await _landingService.getPostById(postId);
      
      if (response != null && response['success'] == true) {
        AppLogger.success('Loaded post details: ${response['data']?['title']}');
        return response['data'];
      } else {
        AppLogger.error('Failed to load post details');
        return null;
      }
    } catch (e) {
      AppLogger.error('Error fetching post details: $e');
      return null;
    }
  }

  // ==================== REGIONS ====================

  Future<void> fetchRegions() async {
    _isLoadingRegions = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getAllRegions();
    
    if (response != null && response['success'] == true) {
      _regions = response['data']['regions'] ?? [];
    } else {
      _errorMessage = 'Failed to load regions';
    }

    _isLoadingRegions = false;
    notifyListeners();
  }

  // ==================== CITIES ====================

  Future<void> fetchCities({String? regionId}) async {
    _isLoadingCities = true;
    _errorMessage = null;
    notifyListeners();

    final response = regionId != null
        ? await _landingService.getCitiesByRegion(regionId)
        : await _landingService.getAllCities();
    
    if (response != null && response['success'] == true) {
      // Cities are nested under 'cities' key like regions
      _cities = response['data']['cities'] ?? [];
    } else {
      _errorMessage = 'Failed to load cities';
    }

    _isLoadingCities = false;
    notifyListeners();
  }

  // ==================== POSTS ====================

  Future<void> fetchPosts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? regionId,
    String? cityId,
    String? postType,
    double? priceMin,
    double? priceMax,
    bool? isActive = true,
    String? search,
    bool? featured,
    bool? verified,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
  }) async {
    _isLoadingPosts = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getAllPosts(
      page: page,
      limit: limit,
      categoryId: categoryId,
      regionId: regionId,
      cityId: cityId,
      postType: postType,
      priceMin: priceMin,
      priceMax: priceMax,
      isActive: isActive,
      search: search,
      featured: featured,
      verified: verified,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    
    if (response != null && response['success'] == true) {
      _posts = response['data']['posts'] ?? [];
      _currentPage = response['data']['currentPage'] ?? 1;
      _totalPages = response['data']['totalPages'] ?? 1;
      _totalItems = response['data']['totalPosts'] ?? 0;
    } else {
      _errorMessage = 'Failed to load posts';
      _posts = [];
    }

    _isLoadingPosts = false;
    notifyListeners();
  }

  // ==================== PRODUCTS ====================

  Future<void> fetchProducts({
    int page = 1,
    int limit = 10,
    String? condition,
    String? productCategory,
    String? categoryId,
    String? regionId,
    String? cityId,
    double? priceMin,
    double? priceMax,
    String? search,
  }) async {
    _isLoadingProducts = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getAllProducts(
      page: page,
      limit: limit,
      condition: condition,
      productCategory: productCategory,
      categoryId: categoryId,
      regionId: regionId,
      cityId: cityId,
      priceMin: priceMin,
      priceMax: priceMax,
      search: search,
    );
    
    if (response != null && response['success'] == true) {
      _products = response['data']['products'] ?? [];
      _currentPage = response['data']['currentPage'] ?? 1;
      _totalPages = response['data']['totalPages'] ?? 1;
      _totalItems = response['data']['totalProducts'] ?? 0;
    } else {
      _errorMessage = 'Failed to load products';
      _products = [];
    }

    _isLoadingProducts = false;
    notifyListeners();
  }

  // ==================== JOB POSTS ====================

  Future<void> fetchJobPosts({
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
    _isLoadingJobPosts = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getAllJobPosts(
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
    
    if (response != null && response['success'] == true) {
      _jobPosts = response['data']['jobPosts'] ?? [];
      _currentPage = response['data']['currentPage'] ?? 1;
      _totalPages = response['data']['totalPages'] ?? 1;
      _totalItems = response['data']['totalJobPosts'] ?? 0;
    } else {
      _errorMessage = 'Failed to load job posts';
      _jobPosts = [];
    }

    _isLoadingJobPosts = false;
    notifyListeners();
  }

  // ==================== RENTAL LISTINGS ====================

  Future<void> fetchRentalListings({
    int page = 1,
    int limit = 10,
    String? propertyType,
    int? bedrooms,
    bool? furnished,
    double? minRent,
    double? maxRent,
  }) async {
    _isLoadingRentals = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getAllRentalListings(
      page: page,
      limit: limit,
      propertyType: propertyType,
      bedrooms: bedrooms,
      furnished: furnished,
      minRent: minRent,
      maxRent: maxRent,
    );
    
    if (response != null && response['success'] == true) {
      _rentalListings = response['data']['rentalListings'] ?? [];
      _currentPage = response['data']['currentPage'] ?? 1;
      _totalPages = response['data']['totalPages'] ?? 1;
      _totalItems = response['data']['totalRentalListings'] ?? 0;
    } else {
      _errorMessage = 'Failed to load rental listings';
      _rentalListings = [];
    }

    _isLoadingRentals = false;
    notifyListeners();
  }

  // ==================== SERVICES ====================

  Future<void> fetchServices({
    int page = 1,
    int limit = 10,
    String? serviceType,
    double? minRate,
    double? maxRate,
  }) async {
    _isLoadingServices = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getAllServices(
      page: page,
      limit: limit,
      serviceType: serviceType,
      minRate: minRate,
      maxRate: maxRate,
    );
    
    if (response != null && response['success'] == true) {
      _services = response['data']['services'] ?? [];
      _currentPage = response['data']['currentPage'] ?? 1;
      _totalPages = response['data']['totalPages'] ?? 1;
      _totalItems = response['data']['totalServices'] ?? 0;
    } else {
      _errorMessage = 'Failed to load services';
      _services = [];
    }

    _isLoadingServices = false;
    notifyListeners();
  }

  // ==================== MATCHMAKING POSTS ====================

  Future<void> fetchMatchmakingPosts({
    int page = 1,
    int limit = 10,
    String? visibility,
    String? religion,
  }) async {
    _isLoadingMatchmaking = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.getAllMatchmakingPosts(
      page: page,
      limit: limit,
      visibility: visibility,
      religion: religion,
    );
    
    if (response != null && response['success'] == true) {
      _matchmakingPosts = response['data']['matchmakingPosts'] ?? [];
      _currentPage = response['data']['currentPage'] ?? 1;
      _totalPages = response['data']['totalPages'] ?? 1;
      _totalItems = response['data']['totalMatchmakingPosts'] ?? 0;
    } else {
      _errorMessage = 'Failed to load matchmaking posts';
      _matchmakingPosts = [];
    }

    _isLoadingMatchmaking = false;
    notifyListeners();
  }

  // ==================== SEARCH ====================

  Future<void> performGlobalSearch({
    required String query,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    if (query.length < 3) {
      _errorMessage = 'Search query must be at least 3 characters';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.globalSearch(
      query: query,
      type: type,
      page: page,
      limit: limit,
    );
    
    if (response != null && response['success'] == true) {
      // Global search returns data with separate arrays: posts, products, jobs, services, rentals
      final data = response['data'] ?? {};
      final List<dynamic> allResults = [];
      
      // Collect all results from different arrays and add type field
      if (data['posts'] != null) {
        for (var post in data['posts']) {
          // Determine type from category
          final categoryName = post['category']?['categoryName']?.toString().toLowerCase() ?? 'post';
          post['type'] = categoryName;
          allResults.add(post);
        }
      }
      if (data['products'] != null) {
        for (var product in data['products']) {
          product['type'] = 'product';
          allResults.add(product);
        }
      }
      if (data['jobs'] != null) {
        for (var job in data['jobs']) {
          job['type'] = 'job';
          allResults.add(job);
        }
      }
      if (data['services'] != null) {
        for (var service in data['services']) {
          service['type'] = 'service';
          allResults.add(service);
        }
      }
      if (data['rentals'] != null) {
        for (var rental in data['rentals']) {
          rental['type'] = 'rental';
          allResults.add(rental);
        }
      }
      
      _searchResults = allResults;
      _currentPage = 1;
      _totalPages = 1;
      _totalItems = allResults.length;
    } else {
      _errorMessage = 'Search failed';
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<void> performAdvancedSearch({
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
    if (query.length < 3) {
      _errorMessage = 'Search query must be at least 3 characters';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _landingService.advancedSearch(
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
    
    if (response != null && response['success'] == true) {
      _searchResults = response['data']['results'] ?? [];
      _currentPage = response['data']['currentPage'] ?? 1;
      _totalPages = response['data']['totalPages'] ?? 1;
      _totalItems = response['data']['totalResults'] ?? 0;
    } else {
      _errorMessage = 'Advanced search failed';
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  // ==================== UTILITY METHODS ====================

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetPagination() {
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    notifyListeners();
  }
}
