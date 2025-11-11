import '../utils/app_logger.dart';
import 'socket_service.dart';

/// Favorites Service
/// Handles favorite/like functionality via Socket.IO
class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final SocketService _socketService = SocketService();

  // Cache for favorite status
  final Map<String, bool> _favoriteStatusCache = {};
  final Map<String, int> _favoriteCountCache = {};

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
      _favoriteStatusCache[targetId] = data['isFavorited'] ?? false;
    });

    // Listen for favorite count updates
    _socketService.on('favorite:count:updated', (data) {
      AppLogger.info('📊 Favorite count updated: ${data['count']}');
      final targetId = data['targetId'] ?? '';
      _favoriteCountCache[targetId] = data['count'] ?? 0;
    });

    // Listen for favorite status response
    _socketService.on('favorite:status', (data) {
      final targetId = data['targetId'] ?? '';
      _favoriteStatusCache[targetId] = data['isFavorited'] ?? false;
    });
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
      
      // Ensure socket is connected
      await _ensureSocketConnected();
      
      AppLogger.info('✅ Socket ready, emitting favorites:get');
      _socketService.emit('favorites:get', {
        'page': page,
        'limit': limit,
      });
    } catch (e) {
      AppLogger.error('Failed to get favorites: $e');
    }
  }

  /// Get favorite status from cache
  bool isFavorited(String targetId) {
    return _favoriteStatusCache[targetId] ?? false;
  }

  /// Get favorite count from cache
  int getFavoriteCount(String targetId) {
    return _favoriteCountCache[targetId] ?? 0;
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
