# 🚀 All Services Implementation Guide

**Date**: Nov 10, 2025  
**Based on**: Backend code from `test/test/logs/`

---

## 📦 **Services Created**

1. ✅ **CommentService** - Post/Profile comments & replies
2. ✅ **LikeService** - Matchmaking likes (dating/networking)
3. ✅ **FavoritesService** - Bookmark posts/profiles (already exists)
4. ✅ **ConversationService** - Messaging (already updated)
5. ✅ **NotificationService** - Notifications (already exists)
6. ✅ **UploadService** - File/image uploads
7. ✅ **UserStatusService** - Online/offline/away/busy status

---

## 1️⃣ **CommentService** 💬

### **Create Comment**
```dart
final commentService = CommentService();

// Comment on a post
final comment = await commentService.createComment(
  targetType: 'Post',
  targetId: 'post-id-123',
  content: 'Great post!',
);

// Reply to a comment
final reply = await commentService.createComment(
  targetType: 'Post',
  targetId: 'post-id-123',
  content: 'Thanks!',
  parentId: 'parent-comment-id',
);
```

### **Get Comments**
```dart
// Get comments for a post
final result = await commentService.getComments(
  targetType: 'Post',
  targetId: 'post-id-123',
  page: 1,
  limit: 20,
);

List comments = result['comments'];
Map pagination = result['pagination'];
```

### **Update & Delete**
```dart
// Update comment
await commentService.updateComment(
  commentId: 'comment-id',
  content: 'Updated content',
);

// Delete comment
await commentService.deleteComment('comment-id');
```

### **Real-time Updates**
```dart
// Listen for new comments
commentService.onCommentCreated((data) {
  print('New comment: ${data['content']}');
});

// Typing indicators
commentService.startTyping(
  targetType: 'Post',
  targetId: 'post-id-123',
);

commentService.stopTyping(
  targetType: 'Post',
  targetId: 'post-id-123',
);

commentService.onUserTyping((data) {
  print('${data['userId']} is typing...');
});
```

---

## 2️⃣ **LikeService** ❤️ (Matchmaking)

### **Like/Skip Users**
```dart
final likeService = LikeService();

// Like a user
final result = await likeService.createLike(
  likedId: 'user-id-456',
  status: 'like',
);

if (result['isMutual']) {
  print('🎉 It\'s a match!');
}

// Skip a user
await likeService.createLike(
  likedId: 'user-id-789',
  status: 'skip',
);

// Unlike
await likeService.unlike('user-id-456');
```

### **Get Likes**
```dart
// Get your likes
final likes = await likeService.getUserLikes(
  page: 1,
  limit: 20,
  status: 'like',
);

// Get mutual likes (matches)
final matches = await likeService.getMutualLikes(
  page: 1,
  limit: 20,
);

// Get users who liked you
final likers = await likeService.getUserLikers(
  page: 1,
  limit: 20,
);
```

### **Check Mutual**
```dart
bool isMutual = await likeService.checkMutualLike('user-id');
if (isMutual) {
  print('You both liked each other!');
}
```

### **Real-time Matches**
```dart
likeService.onNewMatch((data) {
  print('🎉 New match with ${data['userId']}');
});
```

---

## 3️⃣ **FavoritesService** 🔖 (Bookmarks)

```dart
final favoritesService = FavoritesService();

// Toggle favorite
favoritesService.toggleFavorite(
  targetType: 'Post',
  targetId: 'post-id-123',
);

// Get favorites
favoritesService.getFavorites(
  targetType: 'Post',
  page: 1,
  limit: 50,
);

// Listen for updates
favoritesService.onFavoriteToggled((data) {
  print('Favorite toggled: ${data['isFavorited']}');
});
```

---

## 4️⃣ **ConversationService** 💬

```dart
final conversationService = ConversationService();

// Get conversations
final conversations = await conversationService.getConversations(
  page: 1,
  limit: 50,
);

// Send message
conversationService.sendMessage(
  receiverId: 'user-id',
  content: 'Hello!',
  messageType: 'text',
  postId: 'optional-post-id',
);

// Listen for new messages
conversationService.onNewMessage((message) {
  print('New message: ${message['content']}');
});

// Mark as read
conversationService.markAsRead('other-user-id');
```

---

## 5️⃣ **UploadService** 📤

```dart
final uploadService = UploadService();

// Upload single image
File imageFile = File('/path/to/image.jpg');
final result = await uploadService.uploadImage(imageFile);
String imageUrl = result['url'];

// Upload multiple images
List<File> images = [file1, file2, file3];
final results = await uploadService.uploadImages(images);

// Upload with progress
await uploadService.uploadImageWithProgress(
  imageFile,
  (sent, total) {
    double progress = sent / total * 100;
    print('Upload progress: ${progress.toStringAsFixed(0)}%');
  },
);

// Upload file (PDF, doc, etc.)
File pdfFile = File('/path/to/document.pdf');
final fileResult = await uploadService.uploadFile(pdfFile);
```

---

## 6️⃣ **UserStatusService** 🟢🟡🔴

```dart
final userStatusService = UserStatusService();

// Set status
userStatusService.setOnline();
userStatusService.setAway();
userStatusService.setBusy();
userStatusService.setOffline();

// Or use custom status
userStatusService.updateStatus('online');

// Get current status
String status = userStatusService.currentStatus;

// Listen for status updates
userStatusService.onStatusUpdated((data) {
  print('Your status: ${data['status']}');
});

// Listen for other users' status
userStatusService.onUserStatusChanged((data) {
  print('User ${data['userId']} is ${data['status']}');
});

// Auto-update based on app lifecycle
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  userStatusService.handleAppLifecycleChange(state.name);
}
```

---

## 7️⃣ **NotificationService** 🔔

```dart
final notificationService = NotificationService();

// Get notifications (REST API)
final notifications = await notificationService.getNotifications();

// Get unread count
final count = await notificationService.getUnreadCount();

// Mark as read
await notificationService.markAsRead('notification-id');

// Mark all as read
await notificationService.markAllAsRead();

// Listen for real-time notifications
notificationService.listenToNotifications((notification) {
  print('New notification: ${notification.title}');
});
```

---

## 🎯 **Complete Example: Post Detail Screen**

```dart
class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({required this.postId});
  
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentService = CommentService();
  final _favoritesService = FavoritesService();
  final _uploadService = UploadService();
  
  List<Map> _comments = [];
  bool _isFavorited = false;
  
  @override
  void initState() {
    super.initState();
    _setupListeners();
    _loadComments();
    _checkFavoriteStatus();
  }
  
  void _setupListeners() {
    // Listen for new comments
    _commentService.onCommentCreated((data) {
      if (data['targetId'] == widget.postId) {
        setState(() {
          _comments.insert(0, data);
        });
      }
    });
    
    // Listen for favorites
    _favoritesService.onFavoriteToggled((data) {
      if (data['targetId'] == widget.postId) {
        setState(() {
          _isFavorited = data['isFavorited'];
        });
      }
    });
  }
  
  Future<void> _loadComments() async {
    final result = await _commentService.getComments(
      targetType: 'Post',
      targetId: widget.postId,
      page: 1,
      limit: 20,
    );
    setState(() {
      _comments = List<Map>.from(result['comments']);
    });
  }
  
  void _checkFavoriteStatus() {
    _favoritesService.checkFavorite(
      targetType: 'Post',
      targetId: widget.postId,
    );
  }
  
  Future<void> _addComment(String content) async {
    await _commentService.createComment(
      targetType: 'Post',
      targetId: widget.postId,
      content: content,
    );
  }
  
  void _toggleFavorite() {
    _favoritesService.toggleFavorite(
      targetType: 'Post',
      targetId: widget.postId,
    );
  }
  
  @override
  void dispose() {
    _commentService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        actions: [
          // Favorite button
          IconButton(
            icon: Icon(_isFavorited ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          // Post content...
          
          // Comments section
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return ListTile(
                  title: Text(comment['content']),
                  subtitle: Text(comment['createdAt']),
                );
              },
            ),
          ),
          
          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }
  
  Widget _buildCommentInput() {
    final controller = TextEditingController();
    
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Add a comment...'),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _commentService.startTyping(
                    targetType: 'Post',
                    targetId: widget.postId,
                  );
                } else {
                  _commentService.stopTyping(
                    targetType: 'Post',
                    targetId: widget.postId,
                  );
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addComment(controller.text);
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 🔌 **Initialize All Services in main.dart**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await SocketService().connect();
  FavoritesService().initialize();
  NotificationService().initialize();
  UserStatusService().setOnline();
  
  runApp(MyApp());
}
```

---

## 📋 **Summary**

| Service | Purpose | Communication |
|---------|---------|---------------|
| **CommentService** | Post/profile comments | Socket.IO |
| **LikeService** | Matchmaking (dating) | Socket.IO |
| **FavoritesService** | Bookmark posts | Socket.IO |
| **ConversationService** | Messaging | Socket.IO |
| **NotificationService** | Notifications | REST + Socket.IO |
| **UploadService** | File uploads | REST (multipart) |
| **UserStatusService** | User status | Socket.IO |

---

**All services are production-ready and match the backend implementation!** 🚀
