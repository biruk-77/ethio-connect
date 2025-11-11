/// Post Service API Configuration
class PostApiConfig {
  static const String baseUrl = 'https://ethiopost.unitybingo.com';
  static const String localUrl = 'http://localhost:3000';
  
  // Use production URL by default
  static const String apiUrl = baseUrl;
  
  // Endpoints that don't require authentication
  static const String categories = '$apiUrl/api/categories';
  static const String regions = '$apiUrl/api/regions';
  static const String cities = '$apiUrl/api/cities';
  static const String posts = '$apiUrl/api/posts';
  static const String jobPosts = '$apiUrl/api/job-posts';
  static const String products = '$apiUrl/api/products';
  static const String rentalListings = '$apiUrl/api/rental-listings';
  static const String services = '$apiUrl/api/services';
  static const String matchmakingPosts = '$apiUrl/api/matchmaking-posts';
  
  // Search endpoints
  static const String globalSearch = '$apiUrl/api/search/global';
  static const String advancedSearch = '$apiUrl/api/search/advanced';
  
  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
