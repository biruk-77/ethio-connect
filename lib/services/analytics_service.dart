import 'dart:async';
import '../utils/app_logger.dart';
import 'socket_service.dart';

/// Analytics Service - Comprehensive analytics and insights
/// Based on Abel's backend analytics system
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final SocketService _socketService = SocketService();

  // Analytics cache
  final Map<String, Map<String, dynamic>> _analyticsCache = {};
  final Map<String, Map<String, dynamic>> _userBehaviorCache = {};
  final Map<String, Map<String, dynamic>> _contentPerformanceCache = {};
  
  // Stream controllers for real-time analytics
  final _analyticsController = StreamController<Map<String, dynamic>>.broadcast();
  final _userBehaviorController = StreamController<Map<String, dynamic>>.broadcast();
  final _contentPerformanceController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Streams for UI updates
  Stream<Map<String, dynamic>> get analyticsStream => _analyticsController.stream;
  Stream<Map<String, dynamic>> get userBehaviorStream => _userBehaviorController.stream;
  Stream<Map<String, dynamic>> get contentPerformanceStream => _contentPerformanceController.stream;

  /// Initialize analytics listeners
  void initialize() {
    // Listen for analytics data updates
    _socketService.on('analytics:data', (data) {
      AppLogger.info('📊 Analytics data received: ${data['type']}');
      final type = data['type'];
      _analyticsCache[type] = data['analytics'] ?? {};
      
      // Emit to UI stream
      _analyticsController.add({
        'type': type,
        'analytics': data['analytics'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });

    // Listen for user behavior analytics
    _socketService.on('analytics:user:behavior', (data) {
      AppLogger.info('👤 User behavior analytics: ${data['userId']}');
      final userId = data['userId'];
      _userBehaviorCache[userId] = data['behavior'] ?? {};
      
      // Emit to UI stream
      _userBehaviorController.add({
        'userId': userId,
        'behavior': data['behavior'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });

    // Listen for content performance analytics
    _socketService.on('analytics:content:performance', (data) {
      AppLogger.info('📈 Content performance: ${data['contentId']}');
      final contentId = data['contentId'];
      _contentPerformanceCache[contentId] = data['performance'] ?? {};
      
      // Emit to UI stream
      _contentPerformanceController.add({
        'contentId': contentId,
        'contentType': data['contentType'],
        'performance': data['performance'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });

    // Listen for real-time engagement metrics
    _socketService.on('analytics:engagement:realtime', (data) {
      AppLogger.info('⚡ Real-time engagement: ${data['metric']}');
      
      // Emit to UI stream
      _analyticsController.add({
        'type': 'realtime_engagement',
        'metric': data['metric'],
        'value': data['value'],
        'targetId': data['targetId'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });

    AppLogger.info('📊 Analytics Service initialized');
  }

  /// Get comprehensive analytics dashboard
  Future<void> getDashboardAnalytics({
    String period = '7d', // 1d, 7d, 30d, 90d
  }) async {
    try {
      AppLogger.info('📊 Getting dashboard analytics for period: $period');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:dashboard:get', {
        'period': period,
      });
    } catch (e) {
      AppLogger.error('Failed to get dashboard analytics: $e');
    }
  }

  /// Get user engagement analytics
  Future<void> getUserEngagementAnalytics({
    String? userId,
    String period = '30d',
  }) async {
    try {
      AppLogger.info('👤 Getting user engagement analytics: ${userId ?? 'current'} for $period');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:user:engagement:get', {
        if (userId != null) 'userId': userId,
        'period': period,
      });
    } catch (e) {
      AppLogger.error('Failed to get user engagement analytics: $e');
    }
  }

  /// Get content performance analytics
  Future<void> getContentPerformanceAnalytics({
    required String contentId,
    required String contentType,
    String period = '30d',
  }) async {
    try {
      AppLogger.info('📈 Getting content performance: $contentType:$contentId for $period');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:content:performance:get', {
        'contentId': contentId,
        'contentType': contentType,
        'period': period,
      });
    } catch (e) {
      AppLogger.error('Failed to get content performance analytics: $e');
    }
  }

  /// Get platform-wide analytics (admin only)
  Future<void> getPlatformAnalytics({
    String period = '30d',
  }) async {
    try {
      AppLogger.info('🌐 Getting platform analytics for period: $period');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:platform:get', {
        'period': period,
      });
    } catch (e) {
      AppLogger.error('Failed to get platform analytics: $e');
    }
  }

  /// Track user interaction event
  Future<void> trackInteraction({
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('📊 Tracking interaction: $action on $targetType:$targetId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:interaction:track', {
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (metadata != null) 'metadata': metadata,
      });
    } catch (e) {
      AppLogger.error('Failed to track interaction: $e');
    }
  }

  /// Track page/screen view
  Future<void> trackPageView({
    required String page,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('📄 Tracking page view: $page');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:pageview:track', {
        'page': page,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (userId != null) 'userId': userId,
        if (metadata != null) 'metadata': metadata,
      });
    } catch (e) {
      AppLogger.error('Failed to track page view: $e');
    }
  }

  /// Get real-time platform statistics
  Future<void> getRealtimeStats() async {
    try {
      AppLogger.info('⚡ Getting real-time stats');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:realtime:get', {});
    } catch (e) {
      AppLogger.error('Failed to get real-time stats: $e');
    }
  }

  /// Get user behavior patterns
  Future<void> getUserBehaviorAnalytics({
    String? userId,
    String period = '30d',
  }) async {
    try {
      AppLogger.info('🧠 Getting user behavior analytics: ${userId ?? 'current'} for $period');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:user:behavior:get', {
        if (userId != null) 'userId': userId,
        'period': period,
      });
    } catch (e) {
      AppLogger.error('Failed to get user behavior analytics: $e');
    }
  }

  /// Get trending content analytics
  Future<void> getTrendingContentAnalytics({
    String period = '24h',
    int limit = 20,
  }) async {
    try {
      AppLogger.info('🔥 Getting trending content for period: $period');
      
      await _ensureSocketConnected();
      
      _socketService.emit('analytics:content:trending:get', {
        'period': period,
        'limit': limit,
      });
    } catch (e) {
      AppLogger.error('Failed to get trending content analytics: $e');
    }
  }

  /// Get cached analytics data
  Map<String, dynamic>? getCachedAnalytics(String type) {
    return _analyticsCache[type];
  }

  /// Get cached user behavior data
  Map<String, dynamic>? getCachedUserBehavior(String userId) {
    return _userBehaviorCache[userId];
  }

  /// Get cached content performance data
  Map<String, dynamic>? getCachedContentPerformance(String contentId) {
    return _contentPerformanceCache[contentId];
  }

  /// Ensure socket is connected before making requests
  Future<void> _ensureSocketConnected() async {
    if (!_socketService.isConnected) {
      AppLogger.info('🔌 Socket not connected, connecting now...');
      await _socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Clear analytics cache
  void clearCache() {
    _analyticsCache.clear();
    _userBehaviorCache.clear();
    _contentPerformanceCache.clear();
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('analytics:data');
    _socketService.off('analytics:user:behavior');
    _socketService.off('analytics:content:performance');
    _socketService.off('analytics:engagement:realtime');
    _analyticsController.close();
    _userBehaviorController.close();
    _contentPerformanceController.close();
  }
}
