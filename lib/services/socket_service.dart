import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/communication_config.dart';
import '../models/message_model.dart';
import '../utils/app_logger.dart';
import 'auth/auth_service.dart';

/// Socket.IO service for real-time communication
/// Handles messages, notifications, typing indicators, etc.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final AuthService _authService = AuthService();
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Event callbacks
  final Map<String, List<Function>> _eventCallbacks = {};

  /// Initialize and connect to Socket.IO server
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      AppLogger.info('Socket already connected');
      return;
    }

    try {
      // Get JWT token from AuthService (same source where it was saved)
      final token = await _authService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        AppLogger.warning('⚠️ No access token found for Socket connection');
        AppLogger.warning('User must be logged in to use messaging');
        AppLogger.warning('Hint: Make sure AuthService.getAccessToken() returns a valid token');
        throw Exception('Authentication required for messaging');
      }

      AppLogger.info('✓ Token found, connecting to Socket.IO...');
      AppLogger.info('📡 Server: ${CommunicationConfig.socketUrl}');
      AppLogger.info('🔑 Token length: ${token.length} chars');

      _socket = IO.io(
        CommunicationConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'}) // Also add Bearer header
            .build(),
      );

      _setupEventListeners();
      _socket!.connect();
      
      AppLogger.info('🔌 Socket connection initiated...');
    } catch (e) {
      AppLogger.error('❌ Socket connection error: $e');
      rethrow;
    }
  }

  /// Setup all Socket.IO event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Global listener for ALL events (for debugging)
    _socket!.onAny((event, data) {
      AppLogger.info('📨 Socket Event: $event');
      AppLogger.debug('📦 Raw JSON: $data');
    });

    // Connection events
    _socket!.on('connect', (_) {
      _isConnected = true;
      AppLogger.success('✅ Socket.IO connected');
      _notifyListeners('connected', null);
    });

    _socket!.on('disconnect', (_) {
      _isConnected = false;
      AppLogger.warning('Socket.IO disconnected');
      _notifyListeners('disconnected', null);
    });

    _socket!.on('connect_error', (error) {
      AppLogger.error('❌ Socket connection error: $error');
      AppLogger.error('Check if server is running and accepting connections');
    });

    _socket!.on('connect_timeout', (_) {
      AppLogger.error('⏱️ Socket connection timeout');
    });

    _socket!.on('error', (error) {
      AppLogger.error('⚠️ Socket error: $error');
    });

    // Authentication
    _socket!.on('auth:success', (data) {
      AppLogger.success('Socket authenticated: ${data['user']}');
      _notifyListeners('auth:success', data);
    });

    // Messages
    _socket!.on('message:sent', (data) {
      AppLogger.info('Message sent');
      _notifyListeners('message:sent', data);
    });

    _socket!.on('message:new', (data) {
      AppLogger.info('New message received from: ${data['sender']['displayName']}');
      _notifyListeners('message:new', data);
    });

    _socket!.on('message:conversation', (data) {
      AppLogger.info('Conversation loaded: ${data['messages']?.length ?? 0} messages');
      _notifyListeners('message:conversation', data);
    });

    _socket!.on('message:read', (data) {
      AppLogger.info('Messages read');
      _notifyListeners('message:read', data);
    });

    // Typing indicators
    _socket!.on('message:typing:start', (data) {
      _notifyListeners('message:typing:start', data);
    });

    _socket!.on('message:typing:stop', (data) {
      _notifyListeners('message:typing:stop', data);
    });

    // User status
    _socket!.on('user:online', (data) {
      _notifyListeners('user:online', data);
    });

    _socket!.on('user:offline', (data) {
      _notifyListeners('user:offline', data);
    });

    // Notifications
    _socket!.on('notification', (data) {
      AppLogger.info('📬 Notification: ${data['notification']['title']}');
      _notifyListeners('notification', data);
    });

    // Favorites
    _socket!.on('favorites:list', (data) {
      AppLogger.info('📋 Favorites list: ${data['favorites']?.length ?? 0} items');
      _notifyListeners('favorites:list', data);
    });

    _socket!.on('favorite:toggled', (data) {
      AppLogger.info('❤️ Favorite toggled: ${data['action']} - ${data['targetId']}');
      _notifyListeners('favorite:toggled', data);
    });

    _socket!.on('favorite:added', (data) {
      AppLogger.info('➕ Favorite added');
      _notifyListeners('favorite:added', data);
    });

    _socket!.on('favorite:removed', (data) {
      AppLogger.info('➖ Favorite removed');
      _notifyListeners('favorite:removed', data);
    });

    _socket!.on('favorite:status', (data) {
      AppLogger.info('📊 Favorite status: ${data['isFavorited']}');
      _notifyListeners('favorite:status', data);
    });

    _socket!.on('favorite:count:updated', (data) {
      AppLogger.info('🔢 Favorite count: ${data['count']}');
      _notifyListeners('favorite:count:updated', data);
    });

    // Conversations (backend uses message:conversations)
    _socket!.on('message:conversations', (data) {
      AppLogger.info('💬 Conversations list: ${data['conversations']?.length ?? 0} items');
      AppLogger.debug('📦 RAW JSON FROM BACKEND:');
      AppLogger.debug(data.toString());
      _notifyListeners('message:conversations', data);
    });

    // Comments
    _socket!.on('comment:created', (data) {
      AppLogger.info('💬 Comment created');
      _notifyListeners('comment:created', data);
    });

    _socket!.on('comments:list', (data) {
      AppLogger.info('💬 Comments list: ${data['comments']?.length ?? 0} items');
      _notifyListeners('comments:list', data);
    });

    // Likes (Matchmaking)
    _socket!.on('like:created', (data) {
      AppLogger.info('👍 Like created ${data['isMutual'] == true ? "(MATCH! 🎉)" : ""}');
      _notifyListeners('like:created', data);
    });

    _socket!.on('likes:list', (data) {
      AppLogger.info('👍 Likes list: ${data['likes']?.length ?? 0} items');
      _notifyListeners('likes:list', data);
    });

    _socket!.on('likes:matches', (data) {
      AppLogger.info('💕 Matches list: ${data['matches']?.length ?? 0} items');
      _notifyListeners('likes:matches', data);
    });

    _socket!.on('like:match', (data) {
      AppLogger.success('🎉 NEW MATCH! ${data['userId']}');
      _notifyListeners('like:match', data);
    });

    // User Status
    _socket!.on('status:updated', (data) {
      AppLogger.info('🟢 Status updated: ${data['status']}');
      _notifyListeners('status:updated', data);
    });

    _socket!.on('user:status:changed', (data) {
      AppLogger.info('👤 User ${data['userId']} is now ${data['status']}');
      _notifyListeners('user:status:changed', data);
    });

    // Rooms
    _socket!.on('room:joined', (data) {
      AppLogger.info('Joined room: ${data['roomName']}');
      _notifyListeners('room:joined', data);
    });

    _socket!.on('room:left', (data) {
      AppLogger.info('Left room: ${data['roomName']}');
      _notifyListeners('room:left', data);
    });

    // Errors
    _socket!.on('error', (error) {
      AppLogger.error('Socket error: $error');
      _notifyListeners('error', error);
    });
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    if (_socket != null) {
      AppLogger.info('Disconnecting Socket.IO');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  /// Register event listener
  void on(String event, Function callback) {
    if (!_eventCallbacks.containsKey(event)) {
      _eventCallbacks[event] = [];
    }
    _eventCallbacks[event]!.add(callback);
  }

  /// Remove event listener
  void off(String event, [Function? callback]) {
    if (callback != null) {
      _eventCallbacks[event]?.remove(callback);
    } else {
      _eventCallbacks.remove(event);
    }
  }

  /// Notify all listeners for an event
  void _notifyListeners(String event, dynamic data) {
    if (_eventCallbacks.containsKey(event)) {
      // Create a copy to avoid concurrent modification error
      // (callbacks might call off() during iteration)
      final callbacks = List.from(_eventCallbacks[event]!);
      for (var callback in callbacks) {
        callback(data);
      }
    }
  }

  /// Emit event to server
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    } else {
      AppLogger.warning('Socket not connected. Cannot emit event: $event');
    }
  }

  // ==================== MESSAGE METHODS ====================

  /// Send a text message
  void sendMessage({
    required String receiverId,
    required String content,
    String? postId,
    String? postType,
    bool isFirstMessage = false,
    Map<String, dynamic>? metadata,
  }) {
    if (receiverId.isEmpty) {
      AppLogger.warning('⚠️ Cannot send message: receiverId is empty');
      return;
    }
    emit('message:send', {
      'receiverId': receiverId, // Backend uses receiverId
      'content': content,
      'messageType': 'text',
      if (postId != null) 'postId': postId,
      if (postType != null) 'postType': postType,
      'isFirstMessage': isFirstMessage,
      if (metadata != null) 'metadata': metadata,
    });
  }

  /// Send message with image
  void sendImageMessage({
    required String receiverId,
    required String content,
    required List<MessageAttachment> attachments,
    String? postId,
  }) {
    emit('message:send', {
      'partnerId': receiverId, // Backend expects 'partnerId'
      'receiverId': receiverId,
      'content': content,
      'messageType': 'image',
      'attachments': attachments.map((a) => a.toJson()).toList(),
      if (postId != null) 'postId': postId,
    });
  }

  /// Get conversation history
  void getConversation({
    required String otherUserId,
    int page = 1,
    int limit = 50,
    String? postId,
  }) {
    emit('message:conversation:get', {
      'partnerId': otherUserId, // Backend expects 'partnerId'
      'page': page,
      'limit': limit,
      if (postId != null) 'postId': postId,
    });
    
    // Don't auto-join room - backend handles this
  }

  /// Mark conversation as read
  void markConversationRead(String otherUserId, {String? postId}) {
    if (otherUserId.isEmpty) {
      AppLogger.warning('⚠️ Cannot mark conversation read: otherUserId is empty');
      return;
    }
    emit('message:conversation:read', {
      'otherUserId': otherUserId, // Backend expects 'otherUserId'
      if (postId != null) 'postId': postId,
    });
  }

  /// Start typing indicator
  void startTyping(String receiverId, {String? postId}) {
    if (receiverId.isEmpty) return;
    emit('message:typing:start', {
      'receiverId': receiverId, // Backend expects 'receiverId'
      if (postId != null) 'postId': postId,
    });
  }

  /// Stop typing indicator
  void stopTyping(String receiverId, {String? postId}) {
    if (receiverId.isEmpty) return;
    emit('message:typing:stop', {
      'receiverId': receiverId, // Backend expects 'receiverId'
      if (postId != null) 'postId': postId,
    });
  }

  // ==================== ROOM METHODS ====================

  /// Join a room (for post comments, etc.)
  /// roomType: 'post', 'profile', 'conversation', etc.
  /// roomId: The ID of the post/profile/etc.
  void joinRoom(String roomType, String roomId) {
    emit('room:join', {
      'roomType': roomType,
      'roomId': roomId,
    });
  }

  /// Leave a room
  void leaveRoom(String roomType, String roomId) {
    emit('room:leave', {
      'roomType': roomType,
      'roomId': roomId,
    });
  }

  // ==================== ENHANCED ROOM METHODS (Abel's Spec) ====================

  /// Join post room for real-time post updates
  void joinPostRoom(String postId) {
    AppLogger.info('🏠 Joining post room: $postId');
    emit('join:post', {'postId': postId});
  }

  /// Leave post room
  void leavePostRoom(String postId) {
    AppLogger.info('🏠 Leaving post room: $postId');
    emit('leave:post', {'postId': postId});
  }

  /// Join user room for direct messages
  void joinUserRoom(String userId) {
    AppLogger.info('👤 Joining user room: $userId');
    emit('join:user', {'userId': userId});
  }

  /// Leave user room
  void leaveUserRoom(String userId) {
    AppLogger.info('👤 Leaving user room: $userId');
    emit('leave:user', {'userId': userId});
  }

  /// Join conversation room
  void joinConversationRoom(String conversationId) {
    AppLogger.info('💬 Joining conversation room: $conversationId');
    emit('join:conversation', {'conversationId': conversationId});
  }

  /// Leave conversation room
  void leaveConversationRoom(String conversationId) {
    AppLogger.info('💬 Leaving conversation room: $conversationId');
    emit('leave:conversation', {'conversationId': conversationId});
  }

  /// Join multiple rooms at once
  void joinRooms(List<Map<String, String>> rooms) {
    for (var room in rooms) {
      final type = room['type'];
      final id = room['id'];
      if (type != null && id != null) {
        switch (type) {
          case 'post':
            joinPostRoom(id);
            break;
          case 'user':
            joinUserRoom(id);
            break;
          case 'conversation':
            joinConversationRoom(id);
            break;
          default:
            joinRoom(type, id);
        }
      }
    }
  }

  /// Leave all rooms (cleanup)
  void leaveAllRooms() {
    AppLogger.info('🏠 Leaving all rooms');
    emit('leave:all', {});
  }

  // ==================== USER STATUS METHODS ====================

  /// Update user status
  void updateStatus({
    required String status,
    String? customStatus,
  }) {
    emit('user:status:update', {
      'status': status,
      if (customStatus != null) 'customStatus': customStatus,
    });
  }

  /// Get user status
  void getUserStatus(String userId) {
    emit('user:status:get', {
      'userId': userId,
    });
  }

  // ==================== NOTIFICATION METHODS ====================

  /// Send post like notification
  void sendPostLikeNotification({
    required String postOwnerId,
    required Map<String, dynamic> post,
    required Map<String, dynamic> liker,
  }) {
    emit('notification:post:like', {
      'postOwnerId': postOwnerId,
      'post': post,
      'liker': liker,
    });
  }

  /// Send post comment notification
  void sendPostCommentNotification({
    required String postOwnerId,
    required Map<String, dynamic> post,
    required Map<String, dynamic> comment,
    required Map<String, dynamic> commenter,
  }) {
    emit('notification:post:comment', {
      'postOwnerId': postOwnerId,
      'post': post,
      'comment': comment,
      'commenter': commenter,
    });
  }
}
