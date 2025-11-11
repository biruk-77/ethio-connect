import 'dart:async';
import '../services/auth/auth_service.dart';
import '../services/socket_service.dart';
import '../models/message_model.dart';
import '../utils/app_logger.dart';

class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();

  /// Ensure socket is connected before making requests
  Future<void> _ensureSocketConnected() async {
    if (!_socketService.isConnected) {
      AppLogger.info('🔌 Socket not connected, connecting now...');
      await _socketService.connect();
      // Wait a bit for connection to be fully established
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Get all conversations with pagination
  /// NOTE: REST API doesn't exist, using Socket.IO instead
  Future<List<Conversation>> getConversations({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        AppLogger.warning('No auth token for conversations');
        throw Exception('Not authenticated');
      }

      // Ensure socket is connected before making request
      await _ensureSocketConnected();

      AppLogger.info('🔌 Requesting conversations via Socket.IO (page: $page, limit: $limit)');
      
      // Create completer for async Socket.IO response
      final completer = Completer<List<Conversation>>();
      
      // Listen for response (one-time listener)
      void responseHandler(dynamic data) {
        try {
          AppLogger.info('📨 Received conversations response');
          final List conversationsData = data['conversations'] ?? [];
          AppLogger.success('✅ Loaded ${conversationsData.length} conversations via Socket.IO');
          
          final conversations = conversationsData
              .map((c) => Conversation.fromJson(c))
              .toList();
          
          if (!completer.isCompleted) {
            completer.complete(conversations);
            // Remove listener after receiving response
            _socketService.off('message:conversations', responseHandler);
          }
        } catch (e) {
          AppLogger.error('Error parsing conversations: $e');
          if (!completer.isCompleted) {
            completer.completeError(e);
            // Remove listener even on error
            _socketService.off('message:conversations', responseHandler);
          }
        }
      }
      
      _socketService.on('message:conversations', responseHandler);
      
      // Emit request with correct backend event name
      // Backend doesn't need partnerId - it gets userId from socket.userId
      _socketService.emit('message:conversations:get', {
        'page': page,
        'limit': limit,
      });
      
      // Wait for response with timeout
      return await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          AppLogger.warning('⏱️ Conversations request timed out');
          throw Exception('Request timed out after 15 seconds');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to load conversations: $e');
      rethrow;
    }
  }

  /// Send message via Socket.IO
  void sendMessage({
    required String receiverId,
    required String content,
    String messageType = 'text',
    String? postId,
  }) {
    AppLogger.info('📤 Sending message to $receiverId');
    
    _socketService.emit('message:send', {
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
      if (postId != null) 'postId': postId,
    });
  }

  /// Listen for new messages
  void onNewMessage(Function(dynamic) callback) {
    _socketService.on('message:new', callback);
  }

  /// Listen for message sent confirmation
  void onMessageSent(Function(dynamic) callback) {
    _socketService.on('message:sent', callback);
  }

  /// Mark messages as read
  void markAsRead(String otherUserId) {
    AppLogger.info('✅ Marking messages from $otherUserId as read');
    
    _socketService.emit('messages:mark-read', {
      'userId': otherUserId,
    });
  }

  /// Listen for read receipts
  void onMessagesRead(Function(dynamic) callback) {
    _socketService.on('messages:read', callback);
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('message:new');
    _socketService.off('message:sent');
    _socketService.off('messages:read');
  }
}
