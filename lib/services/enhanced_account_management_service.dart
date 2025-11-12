import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';
import '../models/auth/user_model.dart';
import '../services/auth/auth_service.dart';

/// Enhanced Account Management Service - 100% Complete
/// All account and privacy management matching Abel's backend specification
class EnhancedAccountManagementService {
  static final EnhancedAccountManagementService _instance = EnhancedAccountManagementService._internal();
  factory EnhancedAccountManagementService() => _instance;
  EnhancedAccountManagementService._internal();

  final AuthService _authService = AuthService();
  
  // Account state tracking
  final Map<String, bool> _blockedUsers = {};
  final Map<String, DateTime> _blockTimestamps = {};
  final List<String> _reportedUsers = [];
  Map<String, dynamic> _privacySettings = {};
  
  // Stream controllers for real-time updates
  final _accountStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _privacyUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _blockStatusController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Streams for UI updates
  Stream<Map<String, dynamic>> get accountStatusStream => _accountStatusController.stream;
  Stream<Map<String, dynamic>> get privacyUpdateStream => _privacyUpdateController.stream;
  Stream<Map<String, dynamic>> get blockStatusStream => _blockStatusController.stream;

  /// Deactivate user account
  Future<bool> deactivateAccount({
    required String reason,
    String? feedback,
    bool deleteData = false,
  }) async {
    try {
      AppLogger.info('🔒 Deactivating user account');
      
      final response = await http.delete(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/account'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'reason': reason,
          if (feedback != null) 'feedback': feedback,
          'deleteData': deleteData,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Emit account status update
        _accountStatusController.add({
          'status': 'deactivated',
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        AppLogger.success('✅ Account deactivated successfully');
        return true;
      } else {
        throw Exception('Deactivation failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to deactivate account: $e');
      return false;
    }
  }

  /// Request data export
  Future<Map<String, dynamic>?> requestDataExport({
    List<String>? dataTypes, // ['profile', 'posts', 'messages', 'favorites', 'analytics']
    String format = 'json', // 'json', 'csv', 'xml'
    String? email,
  }) async {
    try {
      AppLogger.info('📦 Requesting data export');
      
      final response = await http.post(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/export-data'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (dataTypes != null) 'dataTypes': dataTypes,
          'format': format,
          if (email != null) 'email': email,
          'requestedAt': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 202) {
        final responseData = jsonDecode(response.body);
        
        AppLogger.success('✅ Data export request submitted');
        return responseData;
      } else {
        throw Exception('Data export request failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to request data export: $e');
      return null;
    }
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings({
    bool? showEmail,
    bool? showPhone,
    bool? showLocation,
    bool? showLastSeen,
    bool? allowDirectMessages,
    bool? allowNotifications,
    bool? showProfileInSearch,
    bool? showOnlineStatus,
    String? profileVisibility, // 'public', 'friends', 'private'
    String? messagePermissions, // 'everyone', 'friends', 'no-one'
    List<String>? blockedKeywords,
    Map<String, dynamic>? customSettings,
  }) async {
    try {
      AppLogger.info('🔐 Updating privacy settings');
      
      final settings = <String, dynamic>{};
      
      if (showEmail != null) settings['showEmail'] = showEmail;
      if (showPhone != null) settings['showPhone'] = showPhone;
      if (showLocation != null) settings['showLocation'] = showLocation;
      if (showLastSeen != null) settings['showLastSeen'] = showLastSeen;
      if (allowDirectMessages != null) settings['allowDirectMessages'] = allowDirectMessages;
      if (allowNotifications != null) settings['allowNotifications'] = allowNotifications;
      if (showProfileInSearch != null) settings['showProfileInSearch'] = showProfileInSearch;
      if (showOnlineStatus != null) settings['showOnlineStatus'] = showOnlineStatus;
      if (profileVisibility != null) settings['profileVisibility'] = profileVisibility;
      if (messagePermissions != null) settings['messagePermissions'] = messagePermissions;
      if (blockedKeywords != null) settings['blockedKeywords'] = blockedKeywords;
      if (customSettings != null) settings.addAll(customSettings);
      
      final response = await http.put(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/privacy'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'settings': settings,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _privacySettings = responseData['settings'] ?? settings;
        
        // Emit privacy update
        _privacyUpdateController.add({
          'settings': _privacySettings,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        
        AppLogger.success('✅ Privacy settings updated');
        return true;
      } else {
        throw Exception('Privacy update failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to update privacy settings: $e');
      return false;
    }
  }

  /// Block user
  Future<bool> blockUser({
    required String userId,
    String? reason,
    bool blockMessages = true,
    bool hideProfile = true,
    bool preventTagging = true,
  }) async {
    try {
      AppLogger.info('🚫 Blocking user: $userId');
      
      final response = await http.post(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/block'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'userId': userId,
          if (reason != null) 'reason': reason,
          'blockMessages': blockMessages,
          'hideProfile': hideProfile,
          'preventTagging': preventTagging,
          'blockedAt': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local cache
        _blockedUsers[userId] = true;
        _blockTimestamps[userId] = DateTime.now();
        
        // Emit block status update
        _blockStatusController.add({
          'action': 'blocked',
          'userId': userId,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        AppLogger.success('✅ User blocked successfully');
        return true;
      } else {
        throw Exception('Block user failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to block user: $e');
      return false;
    }
  }

  /// Unblock user
  Future<bool> unblockUser(String userId) async {
    try {
      AppLogger.info('✅ Unblocking user: $userId');
      
      final response = await http.delete(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/block/$userId'),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local cache
        _blockedUsers.remove(userId);
        _blockTimestamps.remove(userId);
        
        // Emit unblock status update
        _blockStatusController.add({
          'action': 'unblocked',
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        AppLogger.success('✅ User unblocked successfully');
        return true;
      } else {
        throw Exception('Unblock user failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to unblock user: $e');
      return false;
    }
  }

  /// Report user
  Future<bool> reportUser({
    required String userId,
    required String reason,
    String? description,
    List<String>? evidence, // URLs to screenshots, messages, etc.
    String? category, // 'spam', 'harassment', 'fake-profile', 'inappropriate-content', 'other'
  }) async {
    try {
      AppLogger.info('🚨 Reporting user: $userId for $reason');
      
      final response = await http.post(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/report'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'userId': userId,
          'reason': reason,
          if (description != null) 'description': description,
          if (evidence != null) 'evidence': evidence,
          if (category != null) 'category': category,
          'reportedAt': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Add to reported users list
        if (!_reportedUsers.contains(userId)) {
          _reportedUsers.add(userId);
        }
        
        AppLogger.success('✅ User reported successfully');
        return true;
      } else {
        throw Exception('Report user failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to report user: $e');
      return false;
    }
  }

  /// Get blocked users list
  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    try {
      AppLogger.info('📋 Getting blocked users list');
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/blocked'),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final blockedUsers = List<Map<String, dynamic>>.from(
          responseData['blockedUsers'] ?? responseData['data'] ?? []
        );
        
        // Update local cache
        _blockedUsers.clear();
        _blockTimestamps.clear();
        for (final blockedUser in blockedUsers) {
          final userId = blockedUser['userId'] ?? blockedUser['id'];
          if (userId != null) {
            _blockedUsers[userId] = true;
            if (blockedUser['blockedAt'] != null) {
              _blockTimestamps[userId] = DateTime.parse(blockedUser['blockedAt']);
            }
          }
        }
        
        AppLogger.success('✅ Got ${blockedUsers.length} blocked users');
        return blockedUsers;
      } else {
        throw Exception('Get blocked users failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to get blocked users: $e');
      return [];
    }
  }

  /// Get current privacy settings
  Future<Map<String, dynamic>?> getPrivacySettings() async {
    try {
      AppLogger.info('⚙️ Getting privacy settings');
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/privacy'),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _privacySettings = responseData['settings'] ?? {};
        
        AppLogger.success('✅ Privacy settings retrieved');
        return _privacySettings;
      } else {
        throw Exception('Get privacy settings failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to get privacy settings: $e');
      return null;
    }
  }

  /// Get account activity log
  Future<List<Map<String, dynamic>>> getAccountActivity({
    int page = 1,
    int limit = 50,
    String? activityType, // 'login', 'settings', 'privacy', 'block', 'report'
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      AppLogger.info('📊 Getting account activity log');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (activityType != null) queryParams['type'] = activityType;
      if (fromDate != null) queryParams['from'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to'] = toDate.toIso8601String();
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/activity', queryParams),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final activities = List<Map<String, dynamic>>.from(
          responseData['activities'] ?? responseData['data'] ?? []
        );
        
        AppLogger.success('✅ Got ${activities.length} activity records');
        return activities;
      } else {
        throw Exception('Get activity failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to get account activity: $e');
      return [];
    }
  }

  /// Download account data
  Future<String?> downloadAccountData(String exportId) async {
    try {
      AppLogger.info('⬇️ Downloading account data: $exportId');
      
      final response = await http.get(
        Uri.https('ethiocms.unitybingo.com', '/api/v1/users/export-data/$exportId'),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        AppLogger.success('✅ Account data downloaded');
        return response.body;
      } else {
        throw Exception('Download failed: ${response.statusCode} ${response.body}');
      }
      
    } catch (e) {
      AppLogger.error('Failed to download account data: $e');
      return null;
    }
  }

  /// Check if user is blocked
  bool isUserBlocked(String userId) {
    return _blockedUsers[userId] == true;
  }

  /// Check if user is reported
  bool isUserReported(String userId) {
    return _reportedUsers.contains(userId);
  }

  /// Get cached privacy settings
  Map<String, dynamic> getCachedPrivacySettings() {
    return Map.from(_privacySettings);
  }

  /// Get cached blocked users
  List<String> getCachedBlockedUsers() {
    return _blockedUsers.keys.toList();
  }

  /// Clear all caches
  void clearCache() {
    _blockedUsers.clear();
    _blockTimestamps.clear();
    _reportedUsers.clear();
    _privacySettings.clear();
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
    _accountStatusController.close();
    _privacyUpdateController.close();
    _blockStatusController.close();
    clearCache();
  }
}
