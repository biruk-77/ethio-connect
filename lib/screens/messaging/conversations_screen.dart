import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/socket_service.dart';
import '../../services/auth/auth_service.dart';
import '../../services/conversation_service.dart';
import '../../models/message_model.dart';
import '../../utils/app_logger.dart';
import '../../theme/app_colors.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();
  final ConversationService _conversationService = ConversationService();

  List<Conversation> _conversations = [];
  bool _isLoading = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Check if user is authenticated first
    final isAuth = await _authService.isAuthenticated();
    if (!isAuth) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to access messages'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      // Connect to socket
      await _socketService.connect();
      
      // Setup listeners
      _setupListeners();
      
      // Load conversations
      await _loadConversations();
    } catch (e) {
      AppLogger.error('Failed to initialize messaging: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupListeners() {
    _socketService.on('connected', (_) {
      setState(() => _isConnected = true);
    });

    _socketService.on('disconnected', (_) {
      setState(() => _isConnected = false);
    });

    // Listen for new messages
    _socketService.on('message:new', (data) {
      _loadConversations(); // Refresh list
    });
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _conversationService.getConversations(
        page: 1,
        limit: 50,
      );
      
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load conversations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Show appropriate error message
        String errorMessage = 'Failed to load conversations';
        Color errorColor = Colors.red;
        
        if (e.toString().contains('404')) {
          errorMessage = '⚠️ Messaging service not available (404)';
          errorColor = Colors.orange;
        } else if (e.toString().contains('401')) {
          errorMessage = 'Authentication failed. Please login again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _socketService.off('connected');
    _socketService.off('disconnected');
    _socketService.off('message:new');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('💬'),
            SizedBox(width: 8),
            Text('Messages'),
          ],
        ),
        actions: [
          // Connection status indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start chatting by messaging sellers!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        itemCount: _conversations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _buildConversationTile(_conversations[index]);
        },
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final hasUnread = conversation.unreadCount > 0;
    final lastMessageTime = conversation.lastMessage?.createdAt;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primary,
            backgroundImage: conversation.otherUser.photoURL != null
                ? NetworkImage(conversation.otherUser.photoURL!)
                : null,
            child: conversation.otherUser.photoURL == null
                ? Text(
                    conversation.otherUser.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          // Online status indicator
          if (conversation.otherUser.status == 'online')
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.otherUser.displayName,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (lastMessageTime != null)
            Text(
              timeago.format(lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage?.content ?? 'No messages',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                color: hasUnread ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userId: conversation.otherUser.id,
              username: conversation.otherUser.displayName,
              photoURL: conversation.otherUser.photoURL,
            ),
          ),
        );
      },
    );
  }
}
