/// Landing Page API Configuration
/// Contains all public endpoints that don't require authentication
class LandingApiConfig {
  // Base URL for Post Service
  static const String baseUrl = 'https://ethiopost.unitybingo.com';
  static const String localUrl = 'http://localhost:3000';
  
  // Use production URL by default
  static const String apiUrl = baseUrl;
  
  // ==================== CATEGORIES ====================
  /// Get all categories
  /// GET /api/categories
  static const String getAllCategories = '$apiUrl/api/categories';
  
  /// Get category by ID
  /// GET /api/categories/:id
  static String getCategoryById(String id) => '$apiUrl/api/categories/$id';
  
  // ==================== REGIONS ====================
  /// Get all regions
  /// GET /api/regions
  static const String getAllRegions = '$apiUrl/api/regions';
  
  /// Get region by ID
  /// GET /api/regions/:id
  static String getRegionById(String id) => '$apiUrl/api/regions/$id';
  
  // ==================== CITIES ====================
  /// Get all cities
  /// GET /api/cities
  static const String getAllCities = '$apiUrl/api/cities';
  
  /// Get cities by region
  /// GET /api/cities/region/:regionId
  static String getCitiesByRegion(String regionId) => 
      '$apiUrl/api/cities/region/$regionId';
  
  /// Get city by ID
  /// GET /api/cities/:id
  static String getCityById(String id) => '$apiUrl/api/cities/$id';
  
  // ==================== POSTS ====================
  /// Get all posts with filters
  /// GET /api/posts
  /// Query params: page, limit, categoryId, regionId, cityId, postType, 
  ///               priceMin, priceMax, isActive, search, sortBy, sortOrder, etc.
  static const String getAllPosts = '$apiUrl/api/posts';
  
  /// Get post by ID
  /// GET /api/posts/:id
  static String getPostById(String id) => '$apiUrl/api/posts/$id';
  
  /// Get posts by category
  /// GET /api/posts/category/:categoryId
  static String getPostsByCategory(String categoryId) => 
      '$apiUrl/api/posts/category/$categoryId';
  
  /// Get posts by user
  /// GET /api/posts/user/:userId
  static String getPostsByUser(String userId) => 
      '$apiUrl/api/posts/user/$userId';
  
  /// Verify post exists
  /// GET /api/posts/:id/verify
  static String verifyPostExists(String id) => '$apiUrl/api/posts/$id/verify';
  
  // ==================== PRODUCTS ====================
  /// Get all products with filters
  /// GET /api/products
  /// Query params: page, limit, condition, productCategory, allowOffers,
  ///               currency, stockQtyMin, stockQtyMax, categoryId, regionId,
  ///               cityId, priceMin, priceMax, search
  static const String getAllProducts = '$apiUrl/api/products';
  
  /// Get product by ID
  /// GET /api/products/:id
  static String getProductById(String id) => '$apiUrl/api/products/$id';
  
  // ==================== JOB POSTS ====================
  /// Get all job posts with filters
  /// GET /api/job-posts
  /// Query params: page, limit, employmentType, experienceLevel, remote,
  ///               salaryMin, salaryMax, company, search
  static const String getAllJobPosts = '$apiUrl/api/job-posts';
  
  /// Get job post by ID
  /// GET /api/job-posts/:id
  static String getJobPostById(String id) => '$apiUrl/api/job-posts/$id';
  
  // ==================== RENTAL LISTINGS ====================
  /// Get all rental listings with filters
  /// GET /api/rental-listings
  /// Query params: page, limit, propertyType, bedrooms, furnished,
  ///               minRent, maxRent
  static const String getAllRentalListings = '$apiUrl/api/rental-listings';
  
  /// Get rental listing by ID
  /// GET /api/rental-listings/:id
  static String getRentalListingById(String id) => 
      '$apiUrl/api/rental-listings/$id';
  
  // ==================== SERVICES ====================
  /// Get all services with filters
  /// GET /api/services
  /// Query params: page, limit, serviceType, minRate, maxRate
  static const String getAllServices = '$apiUrl/api/services';
  
  /// Get service by ID
  /// GET /api/services/:id
  static String getServiceById(String id) => '$apiUrl/api/services/$id';
  
  // ==================== MATCHMAKING POSTS ====================
  /// Get all matchmaking posts with filters
  /// GET /api/matchmaking-posts
  /// Query params: page, limit, visibility, religion
  static const String getAllMatchmakingPosts = '$apiUrl/api/matchmaking-posts';
  
  /// Get matchmaking post by ID
  /// GET /api/matchmaking-posts/:id
  static String getMatchmakingPostById(String id) => 
      '$apiUrl/api/matchmaking-posts/$id';
  
  // ==================== SEARCH ====================
  /// Global search across all content types
  /// GET /api/search/global
  /// Query params: q (required, min 3 chars), type, page, limit
  static const String globalSearch = '$apiUrl/api/search/global';
  
  /// Advanced search with filters
  /// GET /api/search/advanced
  /// Query params: q, categoryId, regionId, cityId, priceMin, priceMax,
  ///               sortBy, sortOrder, page, limit
  static const String advancedSearch = '$apiUrl/api/search/advanced';
  
  // ==================== REQUEST CONFIGURATION ====================
  /// Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // ==================== QUERY PARAMETER BUILDERS ====================
  
  /// Build query parameters for posts
  static Map<String, dynamic> buildPostsQuery({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? regionId,
    String? cityId,
    String? userId,
    String? postType, // 'offer' or 'request'
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
  }) {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    
    if (categoryId != null) params['categoryId'] = categoryId;
    if (regionId != null) params['regionId'] = regionId;
    if (cityId != null) params['cityId'] = cityId;
    if (userId != null) params['userId'] = userId;
    if (postType != null) params['postType'] = postType;
    if (priceMin != null) params['priceMin'] = priceMin;
    if (priceMax != null) params['priceMax'] = priceMax;
    if (isActive != null) params['isActive'] = isActive;
    if (search != null) params['search'] = search;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (featured != null) params['featured'] = featured;
    if (verified != null) params['verified'] = verified;
    if (expiringSoon != null) params['expiringSoon'] = expiringSoon;
    if (urgent != null) params['urgent'] = urgent;
    
    return params;
  }
  
  /// Build query parameters for products
  static Map<String, dynamic> buildProductsQuery({
    int page = 1,
    int limit = 10,
    String? condition, // 'new', 'used', 'refurbished'
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
  }) {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    
    if (condition != null) params['condition'] = condition;
    if (productCategory != null) params['productCategory'] = productCategory;
    if (allowOffers != null) params['allowOffers'] = allowOffers;
    if (currency != null) params['currency'] = currency;
    if (stockQtyMin != null) params['stockQtyMin'] = stockQtyMin;
    if (stockQtyMax != null) params['stockQtyMax'] = stockQtyMax;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (regionId != null) params['regionId'] = regionId;
    if (cityId != null) params['cityId'] = cityId;
    if (priceMin != null) params['priceMin'] = priceMin;
    if (priceMax != null) params['priceMax'] = priceMax;
    if (search != null) params['search'] = search;
    
    return params;
  }
  
  /// Build query parameters for job posts
  static Map<String, dynamic> buildJobPostsQuery({
    int page = 1,
    int limit = 10,
    String? employmentType, // 'full_time', 'part_time', 'contract', 'internship'
    String? experienceLevel, // 'junior', 'mid', 'senior', 'lead'
    bool? remote,
    double? salaryMin,
    double? salaryMax,
    String? company,
    String? search,
  }) {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    
    if (employmentType != null) params['employmentType'] = employmentType;
    if (experienceLevel != null) params['experienceLevel'] = experienceLevel;
    if (remote != null) params['remote'] = remote;
    if (salaryMin != null) params['salaryMin'] = salaryMin;
    if (salaryMax != null) params['salaryMax'] = salaryMax;
    if (company != null) params['company'] = company;
    if (search != null) params['search'] = search;
    
    return params;
  }
  
  /// Build query parameters for rental listings
  static Map<String, dynamic> buildRentalListingsQuery({
    int page = 1,
    int limit = 10,
    String? propertyType,
    int? bedrooms,
    bool? furnished,
    double? minRent,
    double? maxRent,
  }) {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    
    if (propertyType != null) params['propertyType'] = propertyType;
    if (bedrooms != null) params['bedrooms'] = bedrooms;
    if (furnished != null) params['furnished'] = furnished;
    if (minRent != null) params['minRent'] = minRent;
    if (maxRent != null) params['maxRent'] = maxRent;
    
    return params;
  }
  
  /// Build query parameters for services
  static Map<String, dynamic> buildServicesQuery({
    int page = 1,
    int limit = 10,
    String? serviceType,
    double? minRate,
    double? maxRate,
  }) {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    
    if (serviceType != null) params['serviceType'] = serviceType;
    if (minRate != null) params['minRate'] = minRate;
    if (maxRate != null) params['maxRate'] = maxRate;
    
    return params;
  }
  
  /// Build query parameters for matchmaking posts
  static Map<String, dynamic> buildMatchmakingPostsQuery({
    int page = 1,
    int limit = 10,
    String? visibility,
    String? religion,
  }) {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    
    if (visibility != null) params['visibility'] = visibility;
    if (religion != null) params['religion'] = religion;
    
    return params;
  }
  
  /// Build query parameters for global search
  static Map<String, dynamic> buildGlobalSearchQuery({
    required String query,
    String? type, // 'posts', 'products', 'jobs'
    int page = 1,
    int limit = 20,
  }) {
    final Map<String, dynamic> params = {
      'q': query,
      'page': page,
      'limit': limit,
    };
    
    if (type != null) params['type'] = type;
    
    return params;
  }
  
  /// Build query parameters for advanced search
  static Map<String, dynamic> buildAdvancedSearchQuery({
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
  }) {
    final Map<String, dynamic> params = {
      'q': query,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'page': page,
      'limit': limit,
    };
    
    if (categoryId != null) params['categoryId'] = categoryId;
    if (regionId != null) params['regionId'] = regionId;
    if (cityId != null) params['cityId'] = cityId;
    if (priceMin != null) params['priceMin'] = priceMin;
    if (priceMax != null) params['priceMax'] = priceMax;
    
    return params;
  }
}
