import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';
import '../models/auth/user_model.dart';
import '../services/auth/auth_service.dart';

/// Enhanced User Search Service - 100% Complete
/// All user discovery capabilities matching Abel's backend specification
class EnhancedUserSearchService {
  static final EnhancedUserSearchService _instance = EnhancedUserSearchService._internal();
  factory EnhancedUserSearchService() => _instance;
  EnhancedUserSearchService._internal();

  final AuthService _authService = AuthService();
  
  // Cache for search results and suggestions
  final Map<String, List<User>> _searchCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final List<User> _suggestedUsers = [];
  final List<User> _nearbyUsers = [];
  final List<User> _popularUsers = [];
  
  // Cache duration
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // Stream controllers for real-time updates
  final _searchResultsController = StreamController<List<User>>.broadcast();
  final _suggestionsController = StreamController<List<User>>.broadcast();
  final _nearbyUsersController = StreamController<List<User>>.broadcast();
  
  // Streams for UI updates
  Stream<List<User>> get searchResultsStream => _searchResultsController.stream;
  Stream<List<User>> get suggestionsStream => _suggestionsController.stream;
  Stream<List<User>> get nearbyUsersStream => _nearbyUsersController.stream;

  /// Search users with filters
  Future<List<User>> searchUsers({
    required String query,
    String? location,
    int? minAge,
    int? maxAge,
    String? gender,
    List<String>? interests,
    String? profession,
    bool? isVerified,
    int page = 1,
    int limit = 20,
    bool useCache = true,
  }) async {
    try {
      AppLogger.info('🔍 Searching users: "$query"');
      
      // Check cache first
      final cacheKey = _generateCacheKey(
        query: query,
        location: location,
        minAge: minAge,
        maxAge: maxAge,
        gender: gender,
        interests: interests,
        profession: profession,
        isVerified: isVerified,
        page: page,
        limit: limit,
      );
      
      if (useCache && _isValidCache(cacheKey)) {
        AppLogger.info('📋 Returning cached search results');
        final cachedResults = _searchCache[cacheKey]!;
        _searchResultsController.add(cachedResults);
        return cachedResults;
      }
      
      // Build query parameters
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (location != null) queryParams['location'] = location;
      if (minAge != null) queryParams['minAge'] = minAge.toString();
      if (maxAge != null) queryParams['maxAge'] = maxAge.toString();
      if (gender != null) queryParams['gender'] = gender;
      if (interests != null && interests.isNotEmpty) queryParams['interests'] = interests.join(',');
      if (profession != null) queryParams['profession'] = profession;
      if (isVerified != null) queryParams['verified'] = isVerified.toString();
      
      // Make API request
      final uri = Uri.https('ethiocms.unitybingo.com', '/api/v1/users/search', queryParams);
      final response = await http.get(
        uri,
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final usersData = responseData['users'] ?? responseData['data'] ?? [];
        final users = (usersData as List).map((userData) => User.fromJson(userData)).toList();
        
        // Cache results
        _searchCache[cacheKey] = users;
        _cacheTimestamps[cacheKey] = DateTime.now();
        
        // Emit to stream
        _searchResultsController.add(users);
        
        AppLogger.success('✅ Found ${users.length} users matching "$query"');
        return users;
      } else {
        throw Exception('Search failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to search users: $e');
      return [];
    }
  }

  /// Get user suggestions based on interests, location, mutual connections
  Future<List<User>> getUserSuggestions({
    int limit = 10,
    bool useCache = true,
  }) async {
    try {
      AppLogger.info('💡 Getting user suggestions');
      
      // Check cache
      if (useCache && _suggestedUsers.isNotEmpty) {
        AppLogger.info('📋 Returning cached suggestions');
        _suggestionsController.add(_suggestedUsers);
        return _suggestedUsers;
      }
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/suggestions', {
          'limit': limit.toString(),
        }),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final usersData = responseData['suggestions'] ?? responseData['data'] ?? [];
        final users = (usersData as List).map((userData) => User.fromJson(userData)).toList();
        
        // Cache suggestions
        _suggestedUsers.clear();
        _suggestedUsers.addAll(users);
        
        // Emit to stream
        _suggestionsController.add(users);
        
        AppLogger.success('✅ Got ${users.length} user suggestions');
        return users;
      } else {
        throw Exception('Failed to get suggestions: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to get user suggestions: $e');
      return [];
    }
  }

  /// Get nearby users based on location
  Future<List<User>> getNearbyUsers({
    double? latitude,
    double? longitude,
    int radiusKm = 50,
    int limit = 20,
    bool useCache = true,
  }) async {
    try {
      AppLogger.info('📍 Getting nearby users within ${radiusKm}km');
      
      // Check cache
      if (useCache && _nearbyUsers.isNotEmpty) {
        AppLogger.info('📋 Returning cached nearby users');
        _nearbyUsersController.add(_nearbyUsers);
        return _nearbyUsers;
      }
      
      final queryParams = <String, String>{
        'radius': radiusKm.toString(),
        'limit': limit.toString(),
      };
      
      if (latitude != null) queryParams['lat'] = latitude.toString();
      if (longitude != null) queryParams['lng'] = longitude.toString();
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/nearby', queryParams),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final usersData = responseData['nearby'] ?? responseData['data'] ?? [];
        final users = (usersData as List).map((userData) => User.fromJson(userData)).toList();
        
        // Cache nearby users
        _nearbyUsers.clear();
        _nearbyUsers.addAll(users);
        
        // Emit to stream
        _nearbyUsersController.add(users);
        
        AppLogger.success('✅ Found ${users.length} nearby users');
        return users;
      } else {
        throw Exception('Failed to get nearby users: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to get nearby users: $e');
      return [];
    }
  }

  /// Get popular users
  Future<List<User>> getPopularUsers({
    String period = '7d', // '1d', '7d', '30d', 'all'
    int limit = 20,
    bool useCache = true,
  }) async {
    try {
      AppLogger.info('⭐ Getting popular users for period: $period');
      
      // Check cache
      if (useCache && _popularUsers.isNotEmpty) {
        AppLogger.info('📋 Returning cached popular users');
        return _popularUsers;
      }
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/popular', {
          'period': period,
          'limit': limit.toString(),
        }),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final usersData = responseData['popular'] ?? responseData['data'] ?? [];
        final users = (usersData as List).map((userData) => User.fromJson(userData)).toList();
        
        // Cache popular users
        _popularUsers.clear();
        _popularUsers.addAll(users);
        
        AppLogger.success('✅ Got ${users.length} popular users');
        return users;
      } else {
        throw Exception('Failed to get popular users: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to get popular users: $e');
      return [];
    }
  }

  /// Username autocomplete
  Future<List<String>> getUsernameAutocomplete({
    required String query,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('✍️ Getting username autocomplete for: "$query"');
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/autocomplete', {
          'q': query,
          'limit': limit.toString(),
        }),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final suggestions = List<String>.from(responseData['suggestions'] ?? responseData['data'] ?? []);
        
        AppLogger.success('✅ Got ${suggestions.length} username suggestions');
        return suggestions;
      } else {
        throw Exception('Autocomplete failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to get username autocomplete: $e');
      return [];
    }
  }

  /// Advanced search with multiple criteria
  Future<List<User>> advancedSearch({
    String? displayName,
    String? username,
    String? email,
    String? city,
    String? region,
    String? country,
    List<String>? languages,
    List<String>? skills,
    String? education,
    String? workPlace,
    bool? hasProfilePicture,
    bool? isOnline,
    DateTime? lastActiveAfter,
    String? sortBy, // 'relevance', 'date', 'popularity', 'distance'
    String? sortOrder, // 'asc', 'desc'
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('🔍 Performing advanced user search');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      // Add all optional parameters
      if (displayName != null) queryParams['displayName'] = displayName;
      if (username != null) queryParams['username'] = username;
      if (email != null) queryParams['email'] = email;
      if (city != null) queryParams['city'] = city;
      if (region != null) queryParams['region'] = region;
      if (country != null) queryParams['country'] = country;
      if (languages != null && languages.isNotEmpty) queryParams['languages'] = languages.join(',');
      if (skills != null && skills.isNotEmpty) queryParams['skills'] = skills.join(',');
      if (education != null) queryParams['education'] = education;
      if (workPlace != null) queryParams['workPlace'] = workPlace;
      if (hasProfilePicture != null) queryParams['hasProfilePicture'] = hasProfilePicture.toString();
      if (isOnline != null) queryParams['isOnline'] = isOnline.toString();
      if (lastActiveAfter != null) queryParams['lastActiveAfter'] = lastActiveAfter.toIso8601String();
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/search/advanced', queryParams),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final usersData = responseData['users'] ?? responseData['data'] ?? [];
        final users = (usersData as List).map((userData) => User.fromJson(userData)).toList();
        
        AppLogger.success('✅ Advanced search found ${users.length} users');
        return users;
      } else {
        throw Exception('Advanced search failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to perform advanced search: $e');
      return [];
    }
  }

  /// Get cached search results
  List<User>? getCachedSearchResults(String query) {
    final cacheKey = _generateCacheKey(query: query);
    if (_isValidCache(cacheKey)) {
      return _searchCache[cacheKey];
    }
    return null;
  }

  /// Get cached suggestions
  List<User> getCachedSuggestions() {
    return List.from(_suggestedUsers);
  }

  /// Get cached nearby users
  List<User> getCachedNearbyUsers() {
    return List.from(_nearbyUsers);
  }

  /// Get cached popular users
  List<User> getCachedPopularUsers() {
    return List.from(_popularUsers);
  }

  /// Clear all caches
  void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
    _suggestedUsers.clear();
    _nearbyUsers.clear();
    _popularUsers.clear();
  }

  /// Clear specific search cache
  void clearSearchCache(String query) {
    final cacheKey = _generateCacheKey(query: query);
    _searchCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
  }

  /// Generate cache key
  String _generateCacheKey({
    String? query,
    String? location,
    int? minAge,
    int? maxAge,
    String? gender,
    List<String>? interests,
    String? profession,
    bool? isVerified,
    int? page,
    int? limit,
  }) {
    final parts = [
      query ?? '',
      location ?? '',
      minAge?.toString() ?? '',
      maxAge?.toString() ?? '',
      gender ?? '',
      interests?.join(',') ?? '',
      profession ?? '',
      isVerified?.toString() ?? '',
      page?.toString() ?? '',
      limit?.toString() ?? '',
    ];
    return parts.join('|');
  }

  /// Check if cache is valid
  bool _isValidCache(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// Get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    try {
      final token = await _authService.getCurrentUserToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      AppLogger.warning('Could not get auth token: $e');
    }
    
    return headers;
  }

  /// Dispose service
  void dispose() {
    _searchResultsController.close();
    _suggestionsController.close();
    _nearbyUsersController.close();
    clearCache();
  }
}
