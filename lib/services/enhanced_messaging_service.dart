import 'dart:async';
import '../utils/app_logger.dart';
import 'socket_service.dart';
import 'room_management_service.dart';

/// Enhanced Messaging Service - 100% Complete
/// Advanced messaging features beyond basic chat
class EnhancedMessagingService {
  static final EnhancedMessagingService _instance = EnhancedMessagingService._internal();
  factory EnhancedMessagingService() => _instance;
  EnhancedMessagingService._internal();

  final SocketService _socketService = SocketService();
  final RoomManagementService _roomService = RoomManagementService();

  // Advanced messaging cache
  final Map<String, List<dynamic>> _messageSearchResults = {};
  final Map<String, Map<String, dynamic>> _conversationSettings = {};
  final Map<String, List<dynamic>> _messageReactions = {};
  final Map<String, bool> _messageDeliveryStatus = {};
  
  // Stream controllers for advanced features
  final _messageSearchController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageReactionsController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageStatusController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Streams for UI updates
  Stream<Map<String, dynamic>> get messageSearchStream => _messageSearchController.stream;
  Stream<Map<String, dynamic>> get messageReactionsStream => _messageReactionsController.stream;
  Stream<Map<String, dynamic>> get messageStatusStream => _messageStatusController.stream;

  /// Initialize enhanced messaging listeners
  void initialize() {
    // Listen for message search results
    _socketService.on('message:search:results', (data) {
      AppLogger.info('🔍 Message search results: ${data['results']?.length ?? 0} found');
      final query = data['query'];
      _messageSearchResults[query] = data['results'] ?? [];
      
      // Emit to UI stream
      _messageSearchController.add({
        'query': query,
        'results': data['results'],
        'totalCount': data['totalCount'],
      });
    });

    // Listen for message reactions
    _socketService.on('message:reaction:added', (data) {
      AppLogger.info('😀 Message reaction added: ${data['messageId']} - ${data['reaction']}');
      final messageId = data['messageId'];
      _messageReactions.putIfAbsent(messageId, () => []).add(data);
      
      // Emit to UI stream
      _messageReactionsController.add({
        'action': 'added',
        'messageId': messageId,
        'reaction': data['reaction'],
        'userId': data['userId'],
        'reactions': _messageReactions[messageId],
      });
    });

    // Listen for message reaction removal
    _socketService.on('message:reaction:removed', (data) {
      AppLogger.info('😐 Message reaction removed: ${data['messageId']} - ${data['reaction']}');
      final messageId = data['messageId'];
      final reactions = _messageReactions[messageId] ?? [];
      reactions.removeWhere((r) => 
        r['userId'] == data['userId'] && 
        r['reaction'] == data['reaction']
      );
      
      // Emit to UI stream
      _messageReactionsController.add({
        'action': 'removed',
        'messageId': messageId,
        'reaction': data['reaction'],
        'userId': data['userId'],
        'reactions': reactions,
      });
    });

    // Listen for message delivery confirmations
    _socketService.on('message:delivered', (data) {
      AppLogger.info('✅ Message delivered: ${data['messageId']}');
      final messageId = data['messageId'];
      _messageDeliveryStatus[messageId] = true;
      
      // Emit to UI stream
      _messageStatusController.add({
        'messageId': messageId,
        'status': 'delivered',
        'timestamp': data['timestamp'],
      });
    });

    // Listen for message read confirmations
    _socketService.on('message:read:confirmed', (data) {
      AppLogger.info('👁️ Message read: ${data['messageId']}');
      final messageId = data['messageId'];
      
      // Emit to UI stream
      _messageStatusController.add({
        'messageId': messageId,
        'status': 'read',
        'readBy': data['readBy'],
        'timestamp': data['timestamp'],
      });
    });

    // Listen for conversation settings updates
    _socketService.on('conversation:settings:updated', (data) {
      AppLogger.info('⚙️ Conversation settings updated: ${data['conversationId']}');
      final conversationId = data['conversationId'];
      _conversationSettings[conversationId] = data['settings'] ?? {};
    });

    AppLogger.info('💬✨ Enhanced Messaging Service initialized');
  }

  /// Search messages across conversations
  Future<void> searchMessages({
    required String query,
    String? conversationId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('🔍 Searching messages: "$query"');
      
      await _ensureSocketConnected();
      
      _socketService.emit('message:search', {
        'query': query,
        if (conversationId != null) 'conversationId': conversationId,
        'page': page,
        'limit': limit,
      });
    } catch (e) {
      AppLogger.error('Failed to search messages: $e');
    }
  }

  /// Add reaction to a message
  Future<void> addMessageReaction({
    required String messageId,
    required String reaction, // 😀, ❤️, 👍, etc.
  }) async {
    try {
      AppLogger.info('😀 Adding reaction to message: $messageId - $reaction');
      
      await _ensureSocketConnected();
      
      _socketService.emit('message:reaction:add', {
        'messageId': messageId,
        'reaction': reaction,
      });
    } catch (e) {
      AppLogger.error('Failed to add message reaction: $e');
    }
  }

  /// Remove reaction from a message
  Future<void> removeMessageReaction({
    required String messageId,
    required String reaction,
  }) async {
    try {
      AppLogger.info('😐 Removing reaction from message: $messageId - $reaction');
      
      await _ensureSocketConnected();
      
      _socketService.emit('message:reaction:remove', {
        'messageId': messageId,
        'reaction': reaction,
      });
    } catch (e) {
      AppLogger.error('Failed to remove message reaction: $e');
    }
  }

  /// Get message reactions
  Future<void> getMessageReactions(String messageId) async {
    try {
      AppLogger.info('📊 Getting message reactions: $messageId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('message:reactions:get', {
        'messageId': messageId,
      });
    } catch (e) {
      AppLogger.error('Failed to get message reactions: $e');
    }
  }

  /// Send message with advanced features
  Future<void> sendAdvancedMessage({
    required String receiverId,
    required String content,
    String? messageType, // 'text', 'image', 'file', 'voice', 'location'
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    bool requestReadReceipt = false,
  }) async {
    try {
      AppLogger.info('💬✨ Sending advanced message to: $receiverId');
      
      await _ensureSocketConnected();
      
      // Auto-join user room for real-time updates
      _roomService.joinUserRoomIfNeeded(receiverId);
      
      _socketService.emit('message:send:advanced', {
        'receiverId': receiverId,
        'content': content,
        'messageType': messageType ?? 'text',
        if (attachments != null) 'attachments': attachments,
        if (metadata != null) 'metadata': metadata,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        'requestReadReceipt': requestReadReceipt,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      AppLogger.error('Failed to send advanced message: $e');
    }
  }

  /// Update conversation settings
  Future<void> updateConversationSettings({
    required String conversationId,
    bool? muteNotifications,
    String? customBackground,
    Map<String, dynamic>? otherSettings,
  }) async {
    try {
      AppLogger.info('⚙️ Updating conversation settings: $conversationId');
      
      await _ensureSocketConnected();
      
      final settings = <String, dynamic>{};
      if (muteNotifications != null) settings['muteNotifications'] = muteNotifications;
      if (customBackground != null) settings['customBackground'] = customBackground;
      if (otherSettings != null) settings.addAll(otherSettings);
      
      _socketService.emit('conversation:settings:update', {
        'conversationId': conversationId,
        'settings': settings,
      });
    } catch (e) {
      AppLogger.error('Failed to update conversation settings: $e');
    }
  }

  /// Delete message for everyone
  Future<void> deleteMessageForEveryone(String messageId) async {
    try {
      AppLogger.info('🗑️ Deleting message for everyone: $messageId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('message:delete:everyone', {
        'messageId': messageId,
      });
    } catch (e) {
      AppLogger.error('Failed to delete message for everyone: $e');
    }
  }

  /// Edit message content
  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      AppLogger.info('✏️ Editing message: $messageId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('message:edit', {
        'messageId': messageId,
        'newContent': newContent,
        'editedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      AppLogger.error('Failed to edit message: $e');
    }
  }

  /// Forward message to multiple users
  Future<void> forwardMessage({
    required String messageId,
    required List<String> receiverIds,
  }) async {
    try {
      AppLogger.info('📤 Forwarding message: $messageId to ${receiverIds.length} users');
      
      await _ensureSocketConnected();
      
      _socketService.emit('message:forward', {
        'messageId': messageId,
        'receiverIds': receiverIds,
      });
    } catch (e) {
      AppLogger.error('Failed to forward message: $e');
    }
  }

  /// Get cached message search results
  List<dynamic>? getCachedSearchResults(String query) {
    return _messageSearchResults[query];
  }

  /// Get cached message reactions
  List<dynamic>? getCachedMessageReactions(String messageId) {
    return _messageReactions[messageId];
  }

  /// Get cached conversation settings
  Map<String, dynamic>? getCachedConversationSettings(String conversationId) {
    return _conversationSettings[conversationId];
  }

  /// Check message delivery status
  bool? getMessageDeliveryStatus(String messageId) {
    return _messageDeliveryStatus[messageId];
  }

  /// Ensure socket is connected before making requests
  Future<void> _ensureSocketConnected() async {
    if (!_socketService.isConnected) {
      AppLogger.info('🔌 Socket not connected, connecting now...');
      await _socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Clear cache
  void clearCache() {
    _messageSearchResults.clear();
    _conversationSettings.clear();
    _messageReactions.clear();
    _messageDeliveryStatus.clear();
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('message:search:results');
    _socketService.off('message:reaction:added');
    _socketService.off('message:reaction:removed');
    _socketService.off('message:delivered');
    _socketService.off('message:read:confirmed');
    _socketService.off('conversation:settings:updated');
    _messageSearchController.close();
    _messageReactionsController.close();
    _messageStatusController.close();
  }
}
