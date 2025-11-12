import 'dart:async';
import '../utils/app_logger.dart';
import 'socket_service.dart';

/// Comment Typing Service - Handles typing indicators for comments
/// Based on Abel's backend comment typing system
class CommentTypingService {
  static final CommentTypingService _instance = CommentTypingService._internal();
  factory CommentTypingService() => _instance;
  CommentTypingService._internal();

  final SocketService _socketService = SocketService();

  // Track typing users for different targets
  final Map<String, Set<String>> _typingUsers = {};
  
  // Auto-stop timers for typing indicators
  final Map<String, Timer> _typingTimers = {};
  
  // Stream controller for typing updates
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Stream for UI updates
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  /// Initialize comment typing listeners
  void initialize() {
    // Listen for comment typing start events
    _socketService.on('comment:typing:start', (data) {
      final userId = data['userId'];
      final targetId = data['targetId'];
      final targetType = data['targetType'] ?? 'post';
      
      AppLogger.info('⌨️ Comment typing started: $userId on $targetType:$targetId');
      
      _typingUsers.putIfAbsent(targetId, () => {}).add(userId);
      
      // Emit to UI stream
      _typingController.add({
        'action': 'start',
        'userId': userId,
        'targetId': targetId,
        'targetType': targetType,
        'typingUsers': _typingUsers[targetId]?.toList() ?? [],
      });
    });

    // Listen for comment typing stop events
    _socketService.on('comment:typing:stop', (data) {
      final userId = data['userId'];
      final targetId = data['targetId'];
      final targetType = data['targetType'] ?? 'post';
      
      AppLogger.info('⌨️ Comment typing stopped: $userId on $targetType:$targetId');
      
      _typingUsers[targetId]?.remove(userId);
      
      // Emit to UI stream
      _typingController.add({
        'action': 'stop',
        'userId': userId,
        'targetId': targetId,
        'targetType': targetType,
        'typingUsers': _typingUsers[targetId]?.toList() ?? [],
      });
    });

    AppLogger.info('⌨️ Comment Typing Service initialized');
  }

  /// Start typing indicator for a comment target
  void startCommentTyping({
    required String targetId,
    required String targetType,
  }) {
    try {
      AppLogger.info('⌨️ Starting comment typing: $targetType:$targetId');
      
      _socketService.emit('comment:typing:start', {
        'targetId': targetId,
        'targetType': targetType,
      });

      // Cancel existing timer for this target
      _typingTimers[targetId]?.cancel();

      // Auto-stop after 3 seconds
      _typingTimers[targetId] = Timer(const Duration(seconds: 3), () {
        stopCommentTyping(targetId: targetId, targetType: targetType);
      });
    } catch (e) {
      AppLogger.error('Failed to start comment typing: $e');
    }
  }

  /// Stop typing indicator for a comment target
  void stopCommentTyping({
    required String targetId,
    required String targetType,
  }) {
    try {
      AppLogger.info('⌨️ Stopping comment typing: $targetType:$targetId');
      
      _socketService.emit('comment:typing:stop', {
        'targetId': targetId,
        'targetType': targetType,
      });

      // Cancel timer
      _typingTimers[targetId]?.cancel();
      _typingTimers.remove(targetId);
    } catch (e) {
      AppLogger.error('Failed to stop comment typing: $e');
    }
  }

  /// Handle text input change (auto typing management)
  void handleCommentTextChange({
    required String targetId,
    required String targetType,
    required String text,
  }) {
    if (text.trim().isNotEmpty) {
      startCommentTyping(targetId: targetId, targetType: targetType);
    } else {
      stopCommentTyping(targetId: targetId, targetType: targetType);
    }
  }

  /// Get typing users for a target
  List<String> getTypingUsers(String targetId) {
    return _typingUsers[targetId]?.toList() ?? [];
  }

  /// Check if anyone is typing for a target
  bool isAnyoneTyping(String targetId) {
    return _typingUsers[targetId]?.isNotEmpty ?? false;
  }

  /// Check if specific user is typing for a target
  bool isUserTyping(String targetId, String userId) {
    return _typingUsers[targetId]?.contains(userId) ?? false;
  }

  /// Clear typing indicators for a target
  void clearTypingForTarget(String targetId) {
    _typingUsers[targetId]?.clear();
    _typingTimers[targetId]?.cancel();
    _typingTimers.remove(targetId);
  }

  /// Clear all typing indicators
  void clearAllTyping() {
    _typingUsers.clear();
    for (var timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
  }

  /// Clean up listeners and timers
  void dispose() {
    _socketService.off('comment:typing:start');
    _socketService.off('comment:typing:stop');
    
    // Cancel all timers
    for (var timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    
    _typingController.close();
  }
}
