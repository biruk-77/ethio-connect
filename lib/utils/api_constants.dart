/// API Constants and Base URLs
class ApiConstants {
  // Base URLs
  static const String userServiceBaseUrl = 'https://ethiouser.zewdbingo.com';
  static const String postServiceBaseUrl = 'https://ethiopost.unitybingo.com';
  
  // User Service Endpoints
  static const String userAuthLogin = '$userServiceBaseUrl/api/auth/login';
  static const String userAuthRegister = '$userServiceBaseUrl/api/auth/register';
  static const String userAuthMe = '$userServiceBaseUrl/api/auth/me';
  static const String userAuthRefreshToken = '$userServiceBaseUrl/api/auth/refresh-token';
  static const String userProfiles = '$userServiceBaseUrl/api/profiles';
  static const String userRoles = '$userServiceBaseUrl/api/roles';
  static const String userVerifications = '$userServiceBaseUrl/api/verifications';
  
  // Post Service Endpoints
  static const String posts = '$postServiceBaseUrl/api/posts';
  static const String jobPosts = '$postServiceBaseUrl/api/job-posts';
  static const String products = '$postServiceBaseUrl/api/products';
  static const String rentalListings = '$postServiceBaseUrl/api/rental-listings';
  static const String services = '$postServiceBaseUrl/api/services';
  static const String matchmakingPosts = '$postServiceBaseUrl/api/matchmaking-posts';
  static const String categories = '$postServiceBaseUrl/api/categories';
  static const String regions = '$postServiceBaseUrl/api/regions';
  static const String cities = '$postServiceBaseUrl/api/cities';
  
  // Post Categories (from API)
  static const List<Map<String, dynamic>> postCategories = [
    {'id': 'jobs', 'name': 'Jobs', 'icon': '💼', 'emoji': '💼'},
    {'id': 'products', 'name': 'Products', 'icon': '🛍️', 'emoji': '🛍️'},
    {'id': 'rentals', 'name': 'Rentals', 'icon': '🏠', 'emoji': '🏠'},
    {'id': 'services', 'name': 'Services', 'icon': '🔧', 'emoji': '🔧'},
    {'id': 'matchmaking', 'name': 'Matchmaking', 'icon': '💑', 'emoji': '💑'},
    {'id': 'events', 'name': 'Events', 'icon': '🎉', 'emoji': '🎉'},
  ];
  
  // Request timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
