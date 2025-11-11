# 📚 Backend API Reference - Communication Service

**Base URL**: `https://ethiocms.unitybingo.com`

---

## 🔐 **Authentication**
All endpoints require JWT token in the Authorization header:
```
Authorization: Bearer <JWT_TOKEN>
```

---

## 📨 **Messages API**
**Base Path**: `/api/v1/messages`

### **Send Message**
```http
POST /api/v1/messages/send
Headers: Authorization: Bearer <token>
Body: {
  "receiverId": "string",
  "content": "string",
  "messageType": "text" | "image" | "file",
  "attachments": [],
  "postId": "string (optional)",
  "postType": "string (optional)",
  "isFirstMessage": boolean
}
Response: {
  "success": true,
  "data": { Message object }
}
```

### **Get Conversations**
```http
GET /api/v1/messages/conversations?page=1&limit=50
Headers: Authorization: Bearer <token>
Response: {
  "success": true,
  "data": {
    "conversations": [...],
    "pagination": { page, limit, total, pages }
  }
}
```

### **Get Conversation with User**
```http
GET /api/v1/messages/conversation/:userId?page=1&limit=50&postId=xxx
Headers: Authorization: Bearer <token>
Response: {
  "success": true,
  "data": {
    "messages": [...],
    "pagination": { page, limit, total, totalPages }
  }
}
```

### **Mark Messages as Read**
```http
PUT /api/v1/messages/read/:userId
Headers: Authorization: Bearer <token>
Response: { "success": true, "modifiedCount": 5 }
```

### **Get Unread Count**
```http
GET /api/v1/messages/unread-count
Headers: Authorization: Bearer <token>
Response: { "success": true, "count": 12 }
```

### **Delete Message**
```http
DELETE /api/v1/messages/:id
Headers: Authorization: Bearer <token>
Response: { "success": true }
```

---

## 🔔 **Notifications API**
**Base Path**: `/api/v1/notifications`

### **Get Notifications**
```http
GET /api/v1/notifications?limit=20&skip=0&type=message&read=false
Headers: Authorization: Bearer <token>
Query Params:
  - limit: 1-100 (optional)
  - skip: number (optional)
  - type: message | connection_request | connection_accepted | mention | system
  - read: "true" | "false" (optional)
Response: {
  "success": true,
  "data": {
    "notifications": [...],
    "pagination": { total, limit, skip }
  }
}
```

### **Get Unread Count**
```http
GET /api/v1/notifications/unread-count
Headers: Authorization: Bearer <token>
Response: { "success": true, "count": 5 }
```

### **Mark as Read**
```http
PUT /api/v1/notifications/:id/read
Headers: Authorization: Bearer <token>
Response: { "success": true }
```

### **Mark All as Read**
```http
PUT /api/v1/notifications/read-all
Headers: Authorization: Bearer <token>
Response: { "success": true, "modifiedCount": 10 }
```

### **Delete Notification**
```http
DELETE /api/v1/notifications/:id
Headers: Authorization: Bearer <token>
Response: { "success": true }
```

---

## ❤️ **Favorites API** (Socket.IO Events)

### **Toggle Favorite**
```javascript
socket.emit('favorite:toggle', {
  targetType: 'Post' | 'Profile',
  targetId: 'string'
});

// Response
socket.on('favorite:toggled', (data) => {
  // data: { action: 'added' | 'removed', isFavorited: boolean }
});
```

### **Get Favorites**
```javascript
socket.emit('favorites:get', {
  targetType: 'Post' | 'Profile' | null,
  page: 1,
  limit: 50
});

// Response
socket.on('favorites:list', (data) => {
  // data: { favorites: [...], pagination: {...}, grouped: {...} }
});
```

### **Check if Favorited**
```javascript
socket.emit('favorite:check', {
  targetType: 'Post',
  targetId: 'xxx'
});

// Response
socket.on('favorite:status', (data) => {
  // data: { isFavorited: boolean, count: 12 }
});
```

### **Get Favorite Count**
```javascript
socket.emit('favorite:count', {
  targetType: 'Post',
  targetId: 'xxx'
});

// Response
socket.on('favorite:count:updated', (data) => {
  // data: { count: 42 }
});
```

---

## 👍 **Likes API** (Matchmaking - Socket.IO Events)

### **Create Like/Skip**
```javascript
socket.emit('like:create', {
  likedId: 'userId',
  status: 'like' | 'skip'
});

// Response
socket.on('like:created', (data) => {
  // data: { like: {...}, isMutual: boolean }
});
```

### **Get User Likes**
```javascript
socket.emit('likes:get', {
  page: 1,
  limit: 20,
  status: 'like' | 'skip'
});

// Response
socket.on('likes:list', (data) => {
  // data: { likes: [...], pagination: {...} }
});
```

### **Get Mutual Likes (Matches)**
```javascript
socket.emit('likes:mutual', {
  page: 1,
  limit: 20
});

// Response
socket.on('likes:matches', (data) => {
  // data: { matches: [...], pagination: {...} }
});
```

---

## 💬 **Comments API**

### **Create Comment**
```javascript
socket.emit('comment:create', {
  targetType: 'Post' | 'Profile',
  targetId: 'string',
  content: 'string',
  parentId: 'string (optional - for replies)'
});

// Response
socket.on('comment:created', (data) => {
  // data: { success: true, data: {...} }
});
```

### **Get Comments**
```javascript
socket.emit('comments:get', {
  targetType: 'Post',
  targetId: 'xxx',
  page: 1,
  limit: 20
});

// Response
socket.on('comments:list', (data) => {
  // data: { comments: [...], pagination: {...} }
});
```

### **Update Comment**
```javascript
socket.emit('comment:update', {
  commentId: 'xxx',
  content: 'Updated content'
});

// Response
socket.on('comment:updated', (data) => {
  // data: { success: true, data: {...} }
});
```

### **Delete Comment**
```javascript
socket.emit('comment:delete', {
  commentId: 'xxx'
});

// Response
socket.on('comment:deleted', (data) => {
  // data: { success: true }
});
```

---

## 🔌 **Socket.IO Events**

### **Connection**
```javascript
// Connect with JWT token
const socket = io('https://ethiocms.unitybingo.com', {
  auth: { token: 'JWT_TOKEN' },
  transports: ['websocket', 'polling']
});

socket.on('connected', () => {
  console.log('Connected to server');
});

socket.on('authenticated', (user) => {
  console.log('Authenticated:', user);
});

socket.on('disconnected', () => {
  console.log('Disconnected from server');
});
```

### **Join Rooms**
```javascript
socket.emit('room:join', {
  roomType: 'Post' | 'Profile' | 'Conversation',
  roomId: 'xxx'
});

socket.on('room:joined', (data) => {
  // data: { roomName: 'Post:xxx', users: [...] }
});
```

### **Leave Rooms**
```javascript
socket.emit('room:leave', {
  roomType: 'Post',
  roomId: 'xxx'
});

socket.on('room:left', (data) => {
  // data: { roomName: 'Post:xxx' }
});
```

### **Status Updates**
```javascript
socket.emit('status:update', {
  status: 'online' | 'away' | 'busy' | 'offline'
});

socket.on('status:updated', (data) => {
  // data: { userId: 'xxx', status: 'online' }
});

// Listen for other users' status changes
socket.on('user:status:changed', (data) => {
  // data: { userId: 'xxx', status: 'online' }
});
```

### **Typing Indicators**
```javascript
socket.emit('typing:start', {
  targetType: 'Conversation',
  targetId: 'userId'
});

socket.emit('typing:stop', {
  targetType: 'Conversation',
  targetId: 'userId'
});

socket.on('user:typing', (data) => {
  // data: { userId: 'xxx', targetId: 'yyy' }
});

socket.on('user:stop-typing', (data) => {
  // data: { userId: 'xxx', targetId: 'yyy' }
});
```

### **Real-time Messages**
```javascript
socket.on('message:new', (message) => {
  // Received a new message
});

socket.on('message:read', (data) => {
  // Messages marked as read
});

socket.on('message:deleted', (messageId) => {
  // Message deleted
});
```

### **Real-time Notifications**
```javascript
socket.on('notification', (notification) => {
  // Received a new notification
});

socket.on('notification:read', (notificationId) => {
  // Notification marked as read
});
```

---

## 📊 **Data Models**

### **Message**
```typescript
{
  _id: string,
  senderId: string,
  receiverId: string,
  content: string,
  messageType: 'text' | 'image' | 'file',
  attachments: [],
  postId?: string,
  postType?: string,
  isRead: boolean,
  isDeleted: boolean,
  isFirstMessage: boolean,
  readAt?: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### **Notification**
```typescript
{
  _id: string,
  userId: string,
  type: 'message' | 'connection_request' | 'connection_accepted' | 'mention' | 'system',
  title: string,
  body: string,
  data: object,
  senderId?: string,
  priority: 'low' | 'normal' | 'high',
  actionUrl?: string,
  isRead: boolean,
  deliveryStatus: {
    inApp: boolean,
    push: boolean,
    sentAt: Date
  },
  createdAt: Date,
  updatedAt: Date
}
```

### **Favorite**
```typescript
{
  _id: string,
  userId: string,
  targetType: 'Post' | 'Profile',
  targetId: string,
  createdAt: Date
}
```

### **Like** (Matchmaking)
```typescript
{
  _id: string,
  likerId: string,
  likedId: string,
  status: 'like' | 'skip',
  createdAt: Date,
  updatedAt: Date
}
```

### **Comment**
```typescript
{
  _id: string,
  userId: string,
  targetType: 'Post' | 'Profile',
  targetId: string,
  content: string,
  parentId?: string,  // For replies
  repliesCount: number,
  isApproved: boolean,
  isEdited: boolean,
  editedAt?: Date,
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🔑 **Key Differences**

### **Favorites vs Likes**
- **Favorites**: Bookmark posts/profiles (saved items)
  - Events: `favorite:toggle`, `favorites:get`
  - Target types: `Post`, `Profile`
  - Used for: Saving posts for later

- **Likes**: Matchmaking system (dating/networking)
  - Events: `like:create`, `likes:get`, `likes:mutual`
  - Status: `like`, `skip`
  - Used for: User matching, mutual connections

### **Messages**
- Post-based messaging (marketplace inquiries)
- Direct user-to-user conversations
- Supports attachments and typing indicators
- No connection requirement (open messaging)

### **Notifications**
- In-app notifications via Socket.IO
- Push notifications via FCM (Firebase Cloud Messaging)
- Multiple types: messages, connections, system alerts
- Priority levels for delivery

---

## 🚨 **Error Handling**

All responses include:
```json
{
  "success": boolean,
  "data": {...},
  "error": {
    "message": "string",
    "code": "string",
    "statusCode": number
  }
}
```

Common error codes:
- `400` - Bad Request (validation error)
- `401` - Unauthorized (invalid/expired token)
- `403` - Forbidden (no permission)
- `404` - Not Found
- `500` - Internal Server Error

---

## 📝 **Notes**

1. **Authentication**: JWT tokens from User Service (`ethiouser.zewdbingo.com`)
2. **Socket.IO**: Auto-upgrades from HTTP to WebSocket
3. **Pagination**: Most list endpoints support `page` and `limit` params
4. **Real-time**: Use Socket.IO for instant updates, REST API for data fetching
5. **Hybrid Approach**: REST for CRUD, Socket.IO for real-time events

---

## 🔗 **Related Services**

- **User Service**: `https://ethiouser.zewdbingo.com` - Authentication, profiles
- **Post Service**: `https://ethiopost.unitybingo.com` - Posts, products, jobs
- **Communication Service**: `https://ethiocms.unitybingo.com` - Messages, notifications, comments

---

**Last Updated**: Nov 10, 2025
