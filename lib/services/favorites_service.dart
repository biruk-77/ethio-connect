import 'dart:async';
import '../utils/app_logger.dart';
import 'socket_service.dart';

/// Enhanced Favorites Service - 100% Complete
/// Handles favorite/like functionality via Socket.IO with real-time updates
class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final SocketService _socketService = SocketService();

  // Cache for favorite status
  final Map<String, bool> _favoriteStatusCache = {};
  final Map<String, int> _favoriteCountCache = {};
  
  // Stream controllers for real-time updates
  final _favoriteStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _favoriteCountController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Streams for UI updates
  Stream<Map<String, dynamic>> get favoriteStatusStream => _favoriteStatusController.stream;
  Stream<Map<String, dynamic>> get favoriteCountStream => _favoriteCountController.stream;

  /// Initialize listeners
  void initialize() {
    // Listen for favorite added confirmation
    _socketService.on('favorite:added', (data) {
      AppLogger.success('✅ Favorite added: ${data['favorite']['targetId']}');
      final targetId = data['favorite']['targetId'];
      _favoriteStatusCache[targetId] = true;
    });

    // Listen for favorite toggled
    _socketService.on('favorite:toggled', (data) {
      AppLogger.info('🔄 Favorite toggled: ${data['action']}');
      final targetId = data['targetId'] ?? '';
      final isFavorited = data['isFavorited'] ?? false;
      _favoriteStatusCache[targetId] = isFavorited;
      
      // Emit to UI stream
      _favoriteStatusController.add({
        'targetId': targetId,
        'isFavorited': isFavorited,
        'action': data['action'],
      });
    });

    // Listen for favorite count updates
    _socketService.on('favorite:count:updated', (data) {
      AppLogger.info('📊 Favorite count updated: ${data['count']}');
      final targetId = data['targetId'] ?? '';
      final count = data['count'] ?? 0;
      _favoriteCountCache[targetId] = count;
      
      // Emit to UI stream
      _favoriteCountController.add({
        'targetId': targetId,
        'count': count,
      });
    });

    // Listen for favorite status response
    _socketService.on('favorite:status', (data) {
      final targetId = data['targetId'] ?? '';
      final isFavorited = data['isFavorited'] ?? false;
      _favoriteStatusCache[targetId] = isFavorited;
      
      // Emit to UI stream
      _favoriteStatusController.add({
        'targetId': targetId,
        'isFavorited': isFavorited,
      });
    });

    // Listen for favorite removed
    _socketService.on('favorite:removed', (data) {
      AppLogger.info('➖ Favorite removed: ${data['targetId']}');
      final targetId = data['targetId'] ?? '';
      _favoriteStatusCache[targetId] = false;
      
      // Emit to UI stream
      _favoriteStatusController.add({
        'targetId': targetId,
        'isFavorited': false,
        'action': 'removed',
      });
    });

    AppLogger.info('❤️ Favorites Service initialized');
  }

  /// Add post to favorites
  Future<void> addFavorite({
    required String targetType,
    required String targetId,
  }) async {
    try {
      AppLogger.info('❤️ Adding favorite: $targetType $targetId');
      
      _socketService.emit('favorite:add', {
        'targetType': targetType,
        'targetId': targetId,
      });
      
      // Optimistically update cache
      _favoriteStatusCache[targetId] = true;
      
    } catch (e) {
      AppLogger.error('Failed to add favorite: $e');
    }
  }

  /// Toggle favorite on/off
  Future<void> toggleFavorite({
    required String targetType,
    required String targetId,
  }) async {
    try {
      AppLogger.info('🔄 Toggling favorite: $targetType $targetId');
      
      _socketService.emit('favorite:toggle', {
        'targetType': targetType,
        'targetId': targetId,
      });
      
      // Optimistically update cache
      final currentStatus = _favoriteStatusCache[targetId] ?? false;
      _favoriteStatusCache[targetId] = !currentStatus;
      
    } catch (e) {
      AppLogger.error('Failed to toggle favorite: $e');
    }
  }

  /// Check if item is favorited
  Future<void> checkFavorite({
    required String targetType,
    required String targetId,
  }) async {
    try {
      _socketService.emit('favorite:check', {
        'targetType': targetType,
        'targetId': targetId,
      });
    } catch (e) {
      AppLogger.error('Failed to check favorite: $e');
    }
  }

  /// Ensure socket is connected before making requests
  Future<void> _ensureSocketConnected() async {
    if (!_socketService.isConnected) {
      AppLogger.info('🔌 Socket not connected, connecting now...');
      await _socketService.connect();
      // Wait a bit for connection to be fully established
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Get all favorites
  Future<void> getFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('📋 Getting favorites page $page');
      
      await _ensureSocketConnected();
      
      _socketService.emit('favorites:get', {
        'page': page,
        'limit': limit,
      });
    } catch (e) {
      AppLogger.error('Failed to get favorites: $e');
    }
  }

  /// Clear cache
  void clearCache() {
    _favoriteStatusCache.clear();
    _favoriteCountCache.clear();
  }

  /// Listen to specific favorite events
  void on(String event, Function(dynamic) callback) {
    _socketService.on(event, callback);
  }

  /// Remove specific event listener
  void off(String event) {
    _socketService.off(event);
  }
}
