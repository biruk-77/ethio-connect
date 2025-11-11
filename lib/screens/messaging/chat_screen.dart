import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/socket_service.dart';
import '../../services/auth/auth_service.dart';
import '../../models/message_model.dart';
import '../../utils/app_logger.dart';
import '../../theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String? photoURL;
  final String? postId;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.username,
    this.photoURL,
    this.postId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  String? _currentUserId;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Get current user ID
    final user = await _authService.getCurrentUser();
    _currentUserId = user?.id;

    // Setup listeners
    _setupListeners();

    // Load conversation
    _loadConversation();

    // Mark as read
    _socketService.markConversationRead(widget.userId);
  }

  void _setupListeners() {
    // Message sent confirmation
    _socketService.on('message:sent', (data) {
      final message = Message.fromJson(data['message']);
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    });

    // New message received
    _socketService.on('message:new', (data) {
      final message = Message.fromJson(data['message']);
      if (message.senderId == widget.userId) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
        // Auto mark as read
        _socketService.markConversationRead(widget.userId);
      }
    });

    // Conversation history
    _socketService.on('message:conversation', (data) {
      final List messagesList = data['messages'] ?? [];
      setState(() {
        _messages = messagesList
            .map((m) => Message.fromJson(m))
            .toList()
            .reversed
            .toList(); // Reverse to show oldest first
        _isLoading = false;
      });
      _scrollToBottom();
    });

    // Typing indicators
    _socketService.on('message:typing:start', (data) {
      if (data['userId'] == widget.userId) {
        setState(() => _isTyping = true);
      }
    });

    _socketService.on('message:typing:stop', (data) {
      if (data['userId'] == widget.userId) {
        setState(() => _isTyping = false);
      }
    });
  }

  void _loadConversation() {
    _socketService.getConversation(
      otherUserId: widget.userId,
      page: 1,
      limit: 50,
      postId: widget.postId,
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _socketService.sendMessage(
      receiverId: widget.userId,
      content: content,
      postId: widget.postId,
      postType: widget.postId != null ? 'marketplace' : null,
      isFirstMessage: _messages.isEmpty, // First message if no messages yet
    );

    _messageController.clear();
    _stopTyping();
  }

  void _handleTyping() {
    _socketService.startTyping(widget.userId, postId: widget.postId);

    // Cancel existing timer
    _typingTimer?.cancel();

    // Auto-stop after 3 seconds
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _stopTyping();
    });
  }

  void _stopTyping() {
    _socketService.stopTyping(widget.userId, postId: widget.postId);
    _typingTimer?.cancel();
  }

  @override
  void dispose() {
    _socketService.off('message:sent');
    _socketService.off('message:new');
    _socketService.off('message:conversation');
    _socketService.off('message:typing:start');
    _socketService.off('message:typing:stop');
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              backgroundImage: widget.photoURL != null
                  ? NetworkImage(widget.photoURL!)
                  : null,
              child: widget.photoURL == null
                  ? Text(
                      widget.username[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_isTyping)
                    const Text(
                      'typing...',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.message, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Send a message to start chatting!',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (_) => _handleTyping(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == _currentUserId;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead ? Colors.blue : Colors.grey[600],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
