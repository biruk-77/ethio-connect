class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType; // 'text', 'image', 'file'
  final List<MessageAttachment>? attachments;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    this.attachments,
    this.metadata,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Handle senderId - can be String or Object
    String parseSenderId(dynamic sender) {
      if (sender is String) return sender;
      if (sender is Map) return sender['_id'] ?? sender['id'] ?? '';
      return '';
    }
    
    // Handle receiverId - can be String or Object
    String parseReceiverId(dynamic receiver) {
      if (receiver is String) return receiver;
      if (receiver is Map) return receiver['_id'] ?? receiver['id'] ?? '';
      return '';
    }
    
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: parseSenderId(json['senderId']),
      receiverId: parseReceiverId(json['receiverId']),
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => MessageAttachment.fromJson(a))
              .toList()
          : null,
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class MessageAttachment {
  final String url;
  final String type; // 'image', 'file'
  final String? filename;
  final int? size;

  MessageAttachment({
    required this.url,
    required this.type,
    this.filename,
    this.size,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      url: json['url'] ?? '',
      type: json['type'] ?? 'file',
      filename: json['filename'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
      'filename': filename,
      'size': size,
    };
  }
}

class Conversation {
  final String id;
  final ConversationUser otherUser;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    required this.unreadCount,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'] ?? json['id'] ?? '',
      otherUser: ConversationUser.fromJson(json['partner'] ?? json['otherUser'] ?? {}), // Backend returns 'partner'
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}

class ConversationUser {
  final String id;
  final String username;
  final String displayName;
  final String? photoURL;
  final String status; // 'online', 'offline', 'away', 'busy'

  ConversationUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.photoURL,
    this.status = 'offline',
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['username'] ?? 'User',
      photoURL: json['photoURL'],
      status: json['status'] ?? 'offline',
    );
  }
}
