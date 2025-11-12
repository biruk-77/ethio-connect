import '../models/matchmaking_model.dart';
import '../services/api_client.dart';
import '../utils/app_logger.dart';

class MatchmakingService {
  static final ApiClient _apiClient = ApiClient();

  // Get all matchmaking posts (Auth required)
  static Future<List<MatchmakingPost>> getAllMatchmakingPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.apiRequest('GET', '/api/matchmaking-posts');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.get(
        '/api/matchmaking-posts',
        queryParameters: queryParams,
      );

      final List<dynamic> postsJson = response.data['data'] ?? [];
      return postsJson.map((json) => MatchmakingPost.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching matchmaking posts: $e');
      throw Exception('Failed to fetch matchmaking posts: $e');
    }
  }

  // Get matchmaking post by ID (Auth required)
  static Future<MatchmakingPost> getMatchmakingPostById(String id) async {
    try {
      AppLogger.apiRequest('GET', '/api/matchmaking-posts/$id');
      
      final response = await _apiClient.get('/api/matchmaking-posts/$id');
      return MatchmakingPost.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error fetching matchmaking post: $e');
      throw Exception('Failed to fetch matchmaking post: $e');
    }
  }

  // Create matchmaking post (Auth required)
  static Future<MatchmakingPost> createMatchmakingPost({
    required String postId,
    String visibility = 'public',
    String? religion,
    String? ethnicity,
    String? maritalPrefs,
    String? ageRange,
    Map<String, bool>? privacyFlags,
    List<String>? photos,
  }) async {
    try {
      AppLogger.apiRequest('POST', '/api/matchmaking-posts');
      
      final body = {
        'postId': postId,
        'visibility': visibility,
        if (religion != null) 'religion': religion,
        if (ethnicity != null) 'ethnicity': ethnicity,
        if (maritalPrefs != null) 'maritalPrefs': maritalPrefs,
        if (ageRange != null) 'ageRange': ageRange,
        'privacyFlags': privacyFlags ?? {},
        'photos': photos ?? [],
      };

      final response = await _apiClient.post('/api/matchmaking-posts', data: body);
      return MatchmakingPost.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error creating matchmaking post: $e');
      throw Exception('Failed to create matchmaking post: $e');
    }
  }

  // Update matchmaking post (Auth required)
  static Future<MatchmakingPost> updateMatchmakingPost(String id, Map<String, dynamic> updates) async {
    try {
      AppLogger.apiRequest('PUT', '/api/matchmaking-posts/$id');
      
      final response = await _apiClient.put('/api/matchmaking-posts/$id', data: updates);
      return MatchmakingPost.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error updating matchmaking post: $e');
      throw Exception('Failed to update matchmaking post: $e');
    }
  }

  // Delete matchmaking post (Auth required)
  static Future<bool> deleteMatchmakingPost(String id) async {
    try {
      AppLogger.apiRequest('DELETE', '/api/matchmaking-posts/$id');
      
      await _apiClient.delete('/api/matchmaking-posts/$id');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting matchmaking post: $e');
      throw Exception('Failed to delete matchmaking post: $e');
    }
  }

  // Get all matches (Auth required)
  static Future<List<Match>> getAllMatches({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.apiRequest('GET', '/api/matches');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.get(
        '/api/matches',
        queryParameters: queryParams,
      );

      final List<dynamic> matchesJson = response.data['data'] ?? [];
      return matchesJson.map((json) => Match.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching matches: $e');
      throw Exception('Failed to fetch matches: $e');
    }
  }

  // Get my matches (Auth required)
  static Future<List<Match>> getMyMatches({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.apiRequest('GET', '/api/matches/my-matches');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.get(
        '/api/matches/my-matches',
        queryParameters: queryParams,
      );

      final List<dynamic> matchesJson = response.data['data'] ?? [];
      return matchesJson.map((json) => Match.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching my matches: $e');
      throw Exception('Failed to fetch my matches: $e');
    }
  }

  // Get match by ID (Auth required)
  static Future<Match> getMatchById(String id) async {
    try {
      AppLogger.apiRequest('GET', '/api/matches/$id');
      
      final response = await _apiClient.get('/api/matches/$id');
      return Match.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error fetching match: $e');
      throw Exception('Failed to fetch match: $e');
    }
  }

  // Create match (Auth required)
  static Future<Match> createMatch({
    required String userBId,
    String status = 'matched',
    DateTime? matchedAt,
  }) async {
    try {
      AppLogger.apiRequest('POST', '/api/matches');
      
      final body = {
        'userBId': userBId,
        'status': status,
        if (matchedAt != null) 'matchedAt': matchedAt.toIso8601String(),
      };

      final response = await _apiClient.post('/api/matches', data: body);
      return Match.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error creating match: $e');
      throw Exception('Failed to create match: $e');
    }
  }

  // Update match (Auth required)
  static Future<Match> updateMatch(String id, Map<String, dynamic> updates) async {
    try {
      AppLogger.apiRequest('PUT', '/api/matches/$id');
      
      final response = await _apiClient.put('/api/matches/$id', data: updates);
      return Match.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Error updating match: $e');
      throw Exception('Failed to update match: $e');
    }
  }

  // Delete match (Auth required)
  static Future<bool> deleteMatch(String id) async {
    try {
      AppLogger.apiRequest('DELETE', '/api/matches/$id');
      
      await _apiClient.delete('/api/matches/$id');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting match: $e');
      throw Exception('Failed to delete match: $e');
    }
  }
}
