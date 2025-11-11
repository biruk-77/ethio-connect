import 'package:flutter/foundation.dart';
import '../../../models/message_model.dart';
import '../../../services/socket_service.dart';
import '../../../services/conversation_service.dart';
import '../../../utils/app_logger.dart';

/// Chat state management provider
class ChatProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  final ConversationService _conversationService = ConversationService();

  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messagesByConversation = {};
  Map<String, bool> _typingUsers = {};
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Message> getMessages(String conversationId) {
    return _messagesByConversation[conversationId] ?? [];
  }

  bool isUserTyping(String userId) {
    return _typingUsers[userId] ?? false;
  }

  int get unreadCount {
    return _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (!_socketService.isConnected) {
        await _socketService.connect();
      }

      _setupListeners();
      await loadConversations();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger.error('ChatProvider initialization failed: $e');
      notifyListeners();
    }
  }

  void _setupListeners() {
    _socketService.on('message:new', (data) {
      final message = Message.fromJson(data['message']);
      final convId = _getConversationId(message.senderId, message.receiverId);
      
      _messagesByConversation.putIfAbsent(convId, () => []).add(message);
      notifyListeners();
    });

    _socketService.on('message:typing:start', (data) {
      _typingUsers[data['userId']] = true;
      notifyListeners();
    });

    _socketService.on('message:typing:stop', (data) {
      _typingUsers[data['userId']] = false;
      notifyListeners();
    });
  }

  Future<void> loadConversations() async {
    try {
      _conversations = await _conversationService.getConversations(
        page: 1,
        limit: 50,
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load conversations: $e');
    }
  }

  String _getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  @override
  void dispose() {
    _socketService.off('message:new');
    _socketService.off('message:typing:start');
    _socketService.off('message:typing:stop');
    super.dispose();
  }
}
