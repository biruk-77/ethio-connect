# 🎯 Backend Socket.IO Events - Complete Reference

**Source**: `socket.handler.js` from backend

---

## 📨 **MESSAGE EVENTS**

| Flutter Emits | Backend Expects | Flutter Listens | Backend Emits |
|---------------|-----------------|-----------------|---------------|
| `message:send` | `message:send` ✅ | `message:sent` | `message:sent` ✅ |
| `message:send` | `message:send` ✅ | `message:new` | `message:new` ✅ |
| `message:conversations:get` | `message:conversations:get` ✅ | `message:conversations` | `message:conversations` ✅ |
| `message:conversation:get` | `message:conversation:get` | `message:conversation` | `message:conversation` |
| `message:post:inquiries` | `message:post:inquiries` | `message:post:inquiries:list` | `message:post:inquiries:list` |
| `message:read` | `message:read` | `message:read` | `message:read` |
| `message:typing:start` | `message:typing:start` | `message:typing` | `message:typing` |
| `message:typing:stop` | `message:typing:stop` | `message:typing:stop` | `message:typing:stop` |

---

## 💬 **COMMENT EVENTS**

| Flutter Emits | Backend Expects | Flutter Listens | Backend Emits |
|---------------|-----------------|-----------------|---------------|
| `comment:create` | `comment:create` ✅ | `comment:created` | `comment:created` ✅ |
| `comment:create` | `comment:create` ✅ | `comment:new` | `comment:new` ✅ |
| `comment:update` | `comment:update` | `comment:updated` | `comment:updated` |
| `comment:delete` | `comment:delete` | `comment:deleted` | `comment:deleted` |
| `comment:typing:start` | `comment:typing:start` | `comment:typing` | `comment:typing` |
| `comment:typing:stop` | `comment:typing:stop` | `comment:typing:stop` | `comment:typing:stop` |

---

## 👍 **LIKE EVENTS (Matchmaking)**

| Flutter Emits | Backend Expects | Flutter Listens | Backend Emits |
|---------------|-----------------|-----------------|---------------|
| `like:create` | `like:create` ✅ | `like:created` | `like:created` ✅ |
| `like:create` | `like:create` ✅ | `match:new` | `match:new` ✅ |
| `like:create` | `like:create` ✅ | `like:received` | `like:received` ✅ |
| `like:remove` | `like:remove` | `like:removed` | `like:removed` |
| `like:status:get` | `like:status:get` | `like:status` | `like:status` |
| `likes:get` | `likes:get` | `likes:list` | `likes:list` |
| `likers:get` | `likers:get` | `likers:list` | `likers:list` |
| `matches:get` | `matches:get` | `matches:list` | `matches:list` |

---

## ❤️ **FAVORITE EVENTS**

| Flutter Emits | Backend Expects | Flutter Listens | Backend Emits |
|---------------|-----------------|-----------------|---------------|
| `favorite:add` | `favorite:add` ✅ | `favorite:added` | `favorite:added` ✅ |
| `favorite:remove` | `favorite:remove` | `favorite:removed` | `favorite:removed` |
| `favorite:toggle` | `favorite:toggle` ✅ | `favorite:toggled` | `favorite:toggled` ✅ |
| `favorites:get` | `favorites:get` ✅ | `favorites:list` | `favorites:list` ✅ |
| `favorite:check` | `favorite:check` | `favorite:status` | `favorite:status` |
| - | - | `favorite:count:updated` | `favorite:count:updated` |

---

## 👤 **USER STATUS EVENTS**

| Flutter Emits | Backend Expects | Flutter Listens | Backend Emits |
|---------------|-----------------|-----------------|---------------|
| `user:status:update` | `user:status:update` | `user:status:updated` | `user:status:updated` |
| `user:status:get` | `user:status:get` | `user:status` | `user:status` |
| `users:statuses:get` | `users:statuses:get` | `users:statuses` | `users:statuses` |
| - | - | `user:online` | `user:online` |
| - | - | `user:offline` | `user:offline` |
| - | - | `user:status:changed` | `user:status:changed` |

---

## 🏠 **ROOM EVENTS**

| Flutter Emits | Backend Expects | Flutter Listens | Backend Emits |
|---------------|-----------------|-----------------|---------------|
| `room:join` | `room:join` | `room:joined` | `room:joined` |
| `room:leave` | `room:leave` | `room:left` | `room:left` |

---

## 🔔 **NOTIFICATION EVENTS**

| Flutter Emits | Backend Expects | Flutter Listens | Backend Emits |
|---------------|-----------------|-----------------|---------------|
| `notification:post:like` | `notification:post:like` | `notification:sent` | `notification:sent` |
| `notification:post:comment` | `notification:post:comment` | `notification:sent` | `notification:sent` |
| `notification:comment:reply` | `notification:comment:reply` | `notification:sent` | `notification:sent` |
| `notification:post:share` | `notification:post:share` | `notification:sent` | `notification:sent` |
| `notification:mention` | `notification:mention` | `notification:sent` | `notification:sent` |
| - | - | `notification` | `notification` (incoming) |

---

## 🔐 **AUTH EVENTS**

| Flutter Emits | Backend Expects | Flutter Listens | Backend Emits |
|---------------|-----------------|-----------------|---------------|
| - | - | `authenticated` | `authenticated` ✅ |
| - | - | `connect` | `connect` ✅ |
| - | - | `disconnect` | `disconnect` ✅ |
| - | - | `error` | `error` |

---

## ✅ **FIXED EVENTS**

### **Conversations** 
```dart
// OLD ❌
emit: 'conversations:get'
listen: 'conversations:list'

// NEW ✅
emit: 'message:conversations:get'
listen: 'message:conversations'
```

---

## 📋 **Backend Response Format**

### **Conversations**
```json
{
  "conversations": [...],
  "total": 5,
  "timestamp": "2025-11-10T08:25:45.981Z"
}
```

### **Favorites**
```json
{
  "favorites": [...],
  "pagination": {...},
  "timestamp": "2025-11-10T08:25:45.981Z"
}
```

### **Messages**
```json
{
  "message": {...},
  "timestamp": "2025-11-10T08:25:45.981Z"
}
```

---

## 🎯 **Testing Checklist**

- ✅ Conversations now use `message:conversations:get`
- ✅ Favorites already correct
- ✅ Comments already correct
- ✅ Likes already correct
- ✅ Auth events working

**All events now match backend!** 🚀
