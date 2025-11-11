# Socket Messaging Tests

## Setup

### 1. Install socket.io-client

```bash
npm install socket.io-client --save-dev
```

### 2. Get Required Information

You need:
- **Buyer Token** - JWT token for buyer user
- **Seller Token** - JWT token for seller user  
- **Post ID** - ID of a marketplace post

### 3. Update Configuration

Edit `socket-messaging-test.js` and update:

```javascript
const CONFIG = {
    serverUrl: 'http://localhost:5000',
    
    buyer: {
        token: 'YOUR_BUYER_TOKEN_HERE',
    },
    
    seller: {
        token: 'YOUR_SELLER_TOKEN_HERE',
    },
    
    post: {
        id: 'YOUR_POST_ID_HERE',
        type: 'marketplace'
    }
};
```

## Run Tests

```bash
# Make sure Communication Service is running
npm run dev

# In another terminal, run tests
node test/socket-messaging-test.js
```

## What Gets Tested

✅ **Authentication** - Both users connect and authenticate  
✅ **Send Post Inquiry** - Buyer messages seller about post  
✅ **Receive Inquiry** - Seller receives the message  
✅ **Get Post Inquiries** - Seller views all inquiries for post  
✅ **Get Conversation** - Seller opens conversation with buyer  
✅ **Seller Reply** - Seller responds to buyer  
✅ **Buyer Receives Reply** - Buyer gets the response  
✅ **Get All Conversations** - Buyer views all conversations  
✅ **Mark As Read** - Mark message as read  
✅ **Typing Indicators** - Test typing start/stop  
✅ **Mark Conversation As Read** - Mark entire conversation as read  

## Expected Output

```
============================================================
🧪 SOCKET MESSAGING TEST SUITE
============================================================

🔌 Connecting BUYER...
BUYER connected: abc123
Buyer authenticated: john_doe (user-id-123)

🔌 Connecting SELLER...
SELLER connected: def456
Seller authenticated: jane_seller (user-id-456)

[Test 1] ✅ Authentication - PASS
   Both users authenticated

📝 Test 2: Buyer sends inquiry about post
Buyer sending inquiry about post post-123...
Message sent confirmation received
Message ID: msg-789
Post ID: post-123
Is First Message: true

[Test 2] ✅ Send Post Inquiry - PASS
   Message ID: msg-789

... (more tests)

============================================================
📊 TEST RESULTS SUMMARY
============================================================
✅ Test 1: Authentication - PASS
✅ Test 2: Send Post Inquiry - PASS
✅ Test 3: Receive Inquiry - PASS
✅ Test 4: Get Post Inquiries - PASS
✅ Test 5: Get Conversation - PASS
✅ Test 6: Seller Reply - PASS
✅ Test 7: Buyer Receives Reply - PASS
✅ Test 8: Get All Conversations - PASS
✅ Test 9: Mark As Read - PASS
✅ Test 10: Typing Indicators - PASS
✅ Test 11: Mark Conversation As Read - PASS

------------------------------------------------------------
Total Tests: 11
Passed: 11
Failed: 0
Skipped: 0
Success Rate: 100.0%
============================================================
```

## Troubleshooting

### Connection Failed
- Check if Communication Service is running
- Verify `serverUrl` is correct
- Check firewall settings

### Authentication Failed
- Verify tokens are valid and not expired
- Check User Service is running
- Verify token format is correct

### Message Not Received
- Check both sockets are connected
- Verify user IDs are correct
- Check server logs for errors

### Post Not Found
- Verify post ID exists in Post Service
- Check post type is correct
- Ensure post is active

## Manual Testing

If you prefer manual testing, use a tool like:
- **Socket.IO Client** (browser extension)
- **Postman** (WebSocket support)
- **wscat** (command line)

### Example with wscat:

```bash
npm install -g wscat

# Connect
wscat -c "ws://localhost:5000/socket.io/?EIO=4&transport=websocket" \
  --header "Authorization: Bearer YOUR_TOKEN"

# Send message
{"type":"message:send","data":{"receiverId":"seller-id","content":"Hello","postId":"post-123","postType":"marketplace","isFirstMessage":true}}
```
