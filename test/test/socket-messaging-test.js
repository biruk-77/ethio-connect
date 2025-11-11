/**
 * Socket Messaging Test Script
 * Tests all marketplace messaging events with two users
 * 
 * Usage:
 * node test/socket-messaging-test.js
 */

const io = require('socket.io-client');

// ============================================================
// CONFIGURATION - UPDATE THESE VALUES
// ============================================================

const CONFIG = {
    serverUrl: 'http://localhost:5000',
    
    // User 1 (Buyer - tigist)
    buyer: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjIzMjc4NzQsImV4cCI6MTc2MjMyODc3NH0.RQtWW83Wi9hW7I8FfFUnASR_jDOfiF-ooi3gXO_tStY',
        userId: '09a08a5d-fd36-46c0-8974-8ce8489931f9',
        username: 'tigist'
    },
    
    // User 2 (Seller - abel)
    seller: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJhOThhZTFjLTg2YzktNGY5ZS1iOWQ2LTQ1MjE2NzMzNDQ4OSIsInVzZXJuYW1lIjoiYWJlbCIsImVtYWlsIjoiYWJlbEBnbWFpbC5jb20iLCJwaG9uZSI6IisyNTE5MTExMTExMTEiLCJhdXRoUHJvdmlkZXIiOiJwYXNzd29yZCIsImlzVmVyaWZpZWQiOmZhbHNlLCJzdGF0dXMiOiJhY3RpdmUiLCJyb2xlcyI6WyJkb2N0b3IiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6IkpvaG4gRG9lIiwicHJvZmVzc2lvbiI6IlNvZnR3YXJlIERldmVsb3BlciIsInZlcmlmaWNhdGlvblN0YXR1cyI6InByb2Zlc3Npb25hbCIsInBob3RvVXJsIjpudWxsLCJiaW8iOiJTb2Z0d2FyZSBFbmdpbmVlciB3aXRoIDUgeWVhcnMgZXhwZXJpZW5jZSJ9LCJpYXQiOjE3NjIzMjc4MzAsImV4cCI6MTc2MjMyODczMH0.Yb9wBuowK9LukpF6g5fnH7so-J22UkFHSWQqn-71REM',
        userId: 'ba98ae1c-86c9-4f9e-b9d6-452167334489',
        username: 'abel'
    },
    
    // Test Post
    post: {
        id: 'c6ccca98-d629-42aa-a152-b4ed5ef6b0e7',
        type: 'marketplace'
    }
};

// ============================================================
// TEST UTILITIES
// ============================================================

let testResults = [];
let testNumber = 0;

function log(message, type = 'info') {
    const colors = {
        info: '\x1b[36m',    // Cyan
        success: '\x1b[32m', // Green
        error: '\x1b[31m',   // Red
        warning: '\x1b[33m', // Yellow
        reset: '\x1b[0m'
    };
    
    const color = colors[type] || colors.info;
    console.log(`${color}${message}${colors.reset}`);
}

function logTest(testName, status, details = '') {
    testNumber++;
    const emoji = status === 'PASS' ? '✅' : '❌';
    log(`\n[Test ${testNumber}] ${emoji} ${testName} - ${status}`, status === 'PASS' ? 'success' : 'error');
    if (details) log(`   ${details}`, 'info');
    testResults.push({ test: testName, status, details });
}

function wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// ============================================================
// SOCKET CLIENTS
// ============================================================

let buyerSocket = null;
let sellerSocket = null;
let testMessages = [];

function createSocket(name, token) {
    log(`\n🔌 Connecting ${name}...`, 'info');
    
    const socket = io(CONFIG.serverUrl, {
        auth: { token },
        transports: ['websocket'],
        reconnection: false
    });
    
    // Connection events
    socket.on('connect', () => {
        log(`${name} connected: ${socket.id}`, 'success');
    });
    
    socket.on('connect_error', (error) => {
        log(`${name} connection error: ${error.message}`, 'error');
    });
    
    socket.on('disconnect', (reason) => {
        log(`${name} disconnected: ${reason}`, 'warning');
    });
    
    socket.on('error', (error) => {
        log(`${name} error: ${error.message}`, 'error');
    });
    
    return socket;
}

// ============================================================
// TEST SUITE
// ============================================================

async function runTests() {
    log('\n' + '='.repeat(60), 'info');
    log('🧪 SOCKET MESSAGING TEST SUITE', 'info');
    log('='.repeat(60), 'info');
    
    try {
        // Test 1: Authentication
        await testAuthentication();
        await wait(1000);
        
        // Test 2-3: Send inquiry and receive (combined)
        await testSendAndReceiveInquiry();
        await wait(1000);
        
        // Test 4: Get post inquiries
        await testGetPostInquiries();
        await wait(1000);
        
        // Test 5: Get conversation
        await testGetConversation();
        await wait(1000);
        
        // Test 6-7: Seller reply and buyer receives (combined)
        await testSellerReplyAndReceive();
        await wait(1000);
        
        // Test 8: Get all conversations
        await testGetAllConversations();
        await wait(1000);
        
        // Test 9: Mark message as read
        await testMarkAsRead();
        await wait(1000);
        
        // Test 10: Typing indicators
        await testTypingIndicators();
        await wait(1000);
        
        // Test 11: Mark conversation as read
        await testMarkConversationAsRead();
        await wait(1000);
        
        // Print results
        printResults();
        
    } catch (error) {
        log(`\n❌ Test suite failed: ${error.message}`, 'error');
        console.error(error);
    } finally {
        // Cleanup
        if (buyerSocket) buyerSocket.disconnect();
        if (sellerSocket) sellerSocket.disconnect();
        process.exit(0);
    }
}

// ============================================================
// TEST 1: AUTHENTICATION
// ============================================================

async function testAuthentication() {
    log('\n📝 Test 1: Authentication', 'info');
    
    return new Promise((resolve, reject) => {
        let buyerOnline = false;
        let sellerOnline = false;
        let buyerUserId = null;
        let sellerUserId = null;
        
        // Connect buyer
        buyerSocket = createSocket('BUYER', CONFIG.buyer.token);
        
        // Listen for authenticated event to get buyer's user ID
        buyerSocket.on('authenticated', (data) => {
            buyerUserId = data.userId;
            CONFIG.buyer.userId = data.userId;
            CONFIG.buyer.username = data.username || CONFIG.buyer.username || 'buyer';
            log(`Buyer authenticated: ${CONFIG.buyer.username} (${data.userId})`, 'success');
            buyerOnline = true;
            
            if (sellerOnline) {
                logTest('Authentication', 'PASS', 'Both users authenticated');
                resolve();
            }
        });
        
        // Connect seller
        sellerSocket = createSocket('SELLER', CONFIG.seller.token);
        
        // Listen for authenticated event to get seller's user ID
        sellerSocket.on('authenticated', (data) => {
            sellerUserId = data.userId;
            CONFIG.seller.userId = data.userId;
            CONFIG.seller.username = data.username || CONFIG.seller.username || 'seller';
            log(`Seller authenticated: ${CONFIG.seller.username} (${data.userId})`, 'success');
            sellerOnline = true;
            
            if (buyerOnline) {
                logTest('Authentication', 'PASS', 'Both users authenticated');
                resolve();
            }
        });
        
        // Timeout
        setTimeout(() => {
            if (!buyerOnline || !sellerOnline) {
                logTest('Authentication', 'FAIL', 'Timeout waiting for auth');
                reject(new Error('Authentication timeout'));
            }
        }, 5000);
    });
}

// ============================================================
// TEST 2 & 3: SEND AND RECEIVE INQUIRY (COMBINED)
// ============================================================

async function testSendAndReceiveInquiry() {
    log('\n📝 Test 2: Buyer sends inquiry about post', 'info');
    
    return new Promise((resolve) => {
        let messageSent = false;
        let messageReceived = false;
        
        // Set up receiver listener FIRST
        sellerSocket.once('message:new', (data) => {
            log(`✅ Seller received new message`, 'success');
            log(`From: ${data.message.senderId.username}`, 'info');
            log(`Content: ${data.message.content}`, 'info');
            log(`Post ID: ${data.message.postId}`, 'info');
            
            messageReceived = true;
            logTest('Receive Inquiry', 'PASS', `Received from ${data.message.senderId.username}`);
            
            if (messageSent) {
                resolve();
            }
        });
        
        // Set up sender confirmation
        buyerSocket.once('message:sent', (data) => {
            log(`✅ Message sent confirmation received`, 'success');
            log(`Message ID: ${data.message._id}`, 'info');
            log(`Post ID: ${data.message.postId}`, 'info');
            log(`Is First Message: ${data.message.isFirstMessage}`, 'info');
            
            testMessages.push(data.message);
            messageSent = true;
            
            logTest('Send Post Inquiry', 'PASS', `Message ID: ${data.message._id}`);
            
            // Wait a bit for seller to receive
            setTimeout(() => {
                if (!messageReceived) {
                    logTest('Receive Inquiry', 'FAIL', 'Seller did not receive message');
                }
                resolve();
            }, 2000);
        });
        
        // NOW send the message
        log(`Buyer sending inquiry about post ${CONFIG.post.id}...`, 'info');
        buyerSocket.emit('message:send', {
            receiverId: CONFIG.seller.userId,
            content: 'Is this item still available? What\'s the condition?',
            messageType: 'text',
            postId: CONFIG.post.id,
            postType: CONFIG.post.type,
            isFirstMessage: true
        });
        
        // Overall timeout
        setTimeout(() => {
            if (!messageSent) {
                logTest('Send Post Inquiry', 'FAIL', 'Timeout - no confirmation');
            }
            if (!messageReceived) {
                logTest('Receive Inquiry', 'FAIL', 'Timeout - seller did not receive');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST 4: GET POST INQUIRIES
// ============================================================

async function testGetPostInquiries() {
    log('\n📝 Test 4: Get post inquiries', 'info');
    
    return new Promise((resolve) => {
        let resolved = false;
        
        sellerSocket.once('message:post:inquiries:list', (data) => {
            if (resolved) return;
            resolved = true;
            
            log(`Received ${data.total} inquiries`, 'success');
            
            data.inquiries.forEach((inquiry, index) => {
                log(`\nInquiry ${index + 1}:`, 'info');
                log(`  Buyer: ${inquiry.buyer.displayName} (@${inquiry.buyer.username})`, 'info');
                log(`  Last Message: ${inquiry.lastMessage.content}`, 'info');
                log(`  Unread: ${inquiry.unreadCount}`, 'info');
            });
            
            logTest('Get Post Inquiries', 'PASS', `Found ${data.total} inquiries`);
            resolve();
        });
        
        log(`Seller requesting inquiries for post ${CONFIG.post.id}...`, 'info');
        sellerSocket.emit('message:post:inquiries', {
            postId: CONFIG.post.id
        });
        
        setTimeout(() => {
            if (!resolved) {
                resolved = true;
                logTest('Get Post Inquiries', 'FAIL', 'Timeout - no response');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST 5: GET CONVERSATION
// ============================================================

async function testGetConversation() {
    log('\n📝 Test 5: Get conversation', 'info');
    
    return new Promise((resolve) => {
        let resolved = false;
        
        sellerSocket.once('message:conversation', (data) => {
            if (resolved) return;
            resolved = true;
            
            log(`Received conversation with ${data.messages.length} messages`, 'success');
            log(`Post ID: ${data.postId}`, 'info');
            
            data.messages.forEach((msg, index) => {
                const sender = msg.senderId._id === CONFIG.buyer.userId ? 'Buyer' : 'Seller';
                log(`  [${index + 1}] ${sender}: ${msg.content}`, 'info');
            });
            
            logTest('Get Conversation', 'PASS', `${data.messages.length} messages`);
            resolve();
        });
        
        log(`Seller requesting conversation with buyer about post ${CONFIG.post.id}...`, 'info');
        sellerSocket.emit('message:conversation:get', {
            partnerId: CONFIG.buyer.userId,
            postId: CONFIG.post.id,
            limit: 50
        });
        
        setTimeout(() => {
            if (!resolved) {
                resolved = true;
                logTest('Get Conversation', 'FAIL', 'Timeout - no response');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST 6 & 7: SELLER REPLY AND BUYER RECEIVES (COMBINED)
// ============================================================

async function testSellerReplyAndReceive() {
    log('\n📝 Test 6-7: Seller reply and buyer receives', 'info');
    
    return new Promise((resolve) => {
        let replySent = false;
        let replyReceived = false;
        
        // Set up buyer listener FIRST
        buyerSocket.once('message:new', (data) => {
            log(`✅ Buyer received reply`, 'success');
            log(`From: ${data.message.senderId.username}`, 'info');
            log(`Content: ${data.message.content}`, 'info');
            
            replyReceived = true;
            logTest('Buyer Receives Reply', 'PASS', 'Reply received');
            
            if (replySent) {
                resolve();
            }
        });
        
        // Set up seller confirmation
        sellerSocket.once('message:sent', (data) => {
            log(`✅ Seller reply sent`, 'success');
            log(`Message ID: ${data.message._id}`, 'info');
            
            testMessages.push(data.message);
            replySent = true;
            
            logTest('Seller Reply', 'PASS', `Message ID: ${data.message._id}`);
            
            // Wait a bit for buyer to receive
            setTimeout(() => {
                if (!replyReceived) {
                    logTest('Buyer Receives Reply', 'FAIL', 'Buyer did not receive reply');
                }
                resolve();
            }, 2000);
        });
        
        // NOW send the reply
        log(`Seller sending reply...`, 'info');
        sellerSocket.emit('message:send', {
            receiverId: CONFIG.buyer.userId,
            content: 'Yes, it\'s still available! The condition is excellent, barely used.',
            messageType: 'text',
            postId: CONFIG.post.id,
            postType: CONFIG.post.type,
            isFirstMessage: false
        });
        
        // Overall timeout
        setTimeout(() => {
            if (!replySent) {
                logTest('Seller Reply', 'FAIL', 'Timeout - no confirmation');
            }
            if (!replyReceived) {
                logTest('Buyer Receives Reply', 'FAIL', 'Timeout - buyer did not receive');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST 8: GET ALL CONVERSATIONS
// ============================================================

async function testGetAllConversations() {
    log('\n📝 Test 8: Get all conversations', 'info');
    
    return new Promise((resolve) => {
        let resolved = false;
        
        buyerSocket.once('message:conversations', (data) => {
            if (resolved) return;
            resolved = true;
            
            log(`Received ${data.total} conversations`, 'success');
            
            data.conversations.forEach((conv, index) => {
                log(`\nConversation ${index + 1}:`, 'info');
                log(`  Partner: ${conv.partner.displayName}`, 'info');
                log(`  Post ID: ${conv.postId || 'General'}`, 'info');
                log(`  Post Type: ${conv.postType || 'N/A'}`, 'info');
                log(`  Last Message: ${conv.lastMessage.content}`, 'info');
                log(`  Unread: ${conv.unreadCount}`, 'info');
            });
            
            logTest('Get All Conversations', 'PASS', `${data.total} conversations`);
            resolve();
        });
        
        log(`Buyer requesting all conversations...`, 'info');
        buyerSocket.emit('message:conversations:get', {
            limit: 20
        });
        
        setTimeout(() => {
            if (!resolved) {
                resolved = true;
                logTest('Get All Conversations', 'FAIL', 'Timeout - no response');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST 9: MARK AS READ
// ============================================================

async function testMarkAsRead() {
    log('\n📝 Test 9: Mark message as read', 'info');
    
    if (testMessages.length === 0) {
        logTest('Mark As Read', 'SKIP', 'No messages to mark');
        return;
    }
    
    return new Promise((resolve) => {
        const messageId = testMessages[0]._id;
        
        sellerSocket.once('message:read:success', (data) => {
            log(`Message marked as read`, 'success');
            log(`Message ID: ${data.messageId}`, 'info');
            
            logTest('Mark As Read', 'PASS', `Message ${messageId} marked as read`);
            resolve();
        });
        
        buyerSocket.once('message:read', (data) => {
            log(`Buyer notified that message was read by seller`, 'success');
        });
        
        log(`Seller marking message ${messageId} as read...`, 'info');
        sellerSocket.emit('message:read', {
            messageId: messageId
        });
        
        setTimeout(() => {
            logTest('Mark As Read', 'FAIL', 'Timeout - no confirmation');
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST 10: TYPING INDICATORS
// ============================================================

async function testTypingIndicators() {
    log('\n📝 Test 10: Typing indicators', 'info');
    
    return new Promise((resolve) => {
        let typingReceived = false;
        let typingStopReceived = false;
        
        // Seller listens for typing
        sellerSocket.once('message:typing', (data) => {
            log(`Seller sees buyer typing`, 'success');
            log(`User: ${data.username}`, 'info');
            typingReceived = true;
            
            if (typingStopReceived) {
                logTest('Typing Indicators', 'PASS', 'Both typing events received');
                resolve();
            }
        });
        
        sellerSocket.once('message:typing:stop', (data) => {
            log(`Seller sees buyer stopped typing`, 'success');
            typingStopReceived = true;
            
            if (typingReceived) {
                logTest('Typing Indicators', 'PASS', 'Both typing events received');
                resolve();
            }
        });
        
        // Buyer starts typing
        log(`Buyer starts typing...`, 'info');
        buyerSocket.emit('message:typing:start', {
            receiverId: CONFIG.seller.userId
        });
        
        // Buyer stops typing after 1 second
        setTimeout(() => {
            log(`Buyer stops typing...`, 'info');
            buyerSocket.emit('message:typing:stop', {
                receiverId: CONFIG.seller.userId
            });
        }, 1000);
        
        setTimeout(() => {
            if (!typingReceived || !typingStopReceived) {
                logTest('Typing Indicators', 'FAIL', 'Did not receive all typing events');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST 11: MARK CONVERSATION AS READ
// ============================================================

async function testMarkConversationAsRead() {
    log('\n📝 Test 11: Mark conversation as read', 'info');
    
    return new Promise((resolve) => {
        sellerSocket.once('message:conversation:read:success', (data) => {
            log(`Conversation marked as read`, 'success');
            log(`Other User ID: ${data.otherUserId}`, 'info');
            
            logTest('Mark Conversation As Read', 'PASS', 'Conversation marked as read');
            resolve();
        });
        
        buyerSocket.once('message:conversation:read', (data) => {
            log(`Buyer notified that seller read the conversation`, 'success');
        });
        
        log(`Seller marking conversation with buyer as read...`, 'info');
        sellerSocket.emit('message:conversation:read', {
            otherUserId: CONFIG.buyer.userId
        });
        
        setTimeout(() => {
            logTest('Mark Conversation As Read', 'FAIL', 'Timeout - no confirmation');
            resolve();
        }, 5000);
    });
}

// ============================================================
// PRINT RESULTS
// ============================================================

function printResults() {
    log('\n' + '='.repeat(60), 'info');
    log('📊 TEST RESULTS SUMMARY', 'info');
    log('='.repeat(60), 'info');
    
    const passed = testResults.filter(r => r.status === 'PASS').length;
    const failed = testResults.filter(r => r.status === 'FAIL').length;
    const skipped = testResults.filter(r => r.status === 'SKIP').length;
    const total = testResults.length;
    
    testResults.forEach((result, index) => {
        const emoji = result.status === 'PASS' ? '✅' : result.status === 'FAIL' ? '❌' : '⏭️';
        log(`${emoji} Test ${index + 1}: ${result.test} - ${result.status}`, 
            result.status === 'PASS' ? 'success' : result.status === 'FAIL' ? 'error' : 'warning');
    });
    
    log('\n' + '-'.repeat(60), 'info');
    log(`Total Tests: ${total}`, 'info');
    log(`Passed: ${passed}`, 'success');
    log(`Failed: ${failed}`, failed > 0 ? 'error' : 'info');
    log(`Skipped: ${skipped}`, 'warning');
    log(`Success Rate: ${((passed / total) * 100).toFixed(1)}%`, 
        passed === total ? 'success' : 'warning');
    log('='.repeat(60) + '\n', 'info');
}

// ============================================================
// RUN TESTS
// ============================================================

// Check configuration
if (CONFIG.buyer.token === 'BUYER_TOKEN_HERE' || 
    CONFIG.seller.token === 'SELLER_TOKEN_HERE' ||
    CONFIG.post.id === 'POST_ID_HERE') {
    log('\n❌ ERROR: Please update the configuration in the script!', 'error');
    log('Update these values:', 'warning');
    log('  - CONFIG.buyer.token', 'warning');
    log('  - CONFIG.seller.token', 'warning');
    log('  - CONFIG.post.id', 'warning');
    process.exit(1);
}

// Run the test suite
runTests().catch(error => {
    log(`\n❌ Fatal error: ${error.message}`, 'error');
    console.error(error);
    process.exit(1);
});
