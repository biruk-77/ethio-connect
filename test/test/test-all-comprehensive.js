/**
 * Comprehensive Test Suite for Communication Service
 * Tests all major functionalities with proper event handling
 */

const io = require('socket.io-client');
const config = require('./test-config');

// Test configuration
const SERVER_URL = config.serverUrl || 'http://localhost:5000';
const USER1_TOKEN = config.user1.token;
const USER2_TOKEN = config.user2.token;
const POST_ID = config.post.id;

// Test state
let user1Socket, user2Socket;
let user1Id, user2Id;
let testResults = {
    passed: 0,
    failed: 0,
    total: 0
};

// Test categories
const tests = {
    authentication: [],
    messaging: [],
    comments: [],
    notifications: [],
    likes: [],
    favorites: [],
    userStatus: []
};

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║     COMPREHENSIVE COMMUNICATION SERVICE TEST          ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

// ============================================================
// UTILITY FUNCTIONS
// ============================================================

function logTest(category, name, status, details = '') {
    const icon = status === 'PASS' ? '✅' : '❌';
    console.log(`${icon} [${category}] ${name}`);
    if (details) console.log(`   ${details}`);
    
    testResults.total++;
    if (status === 'PASS') {
        testResults.passed++;
    } else {
        testResults.failed++;
    }
}

function logSection(title) {
    console.log(`\n${'─'.repeat(60)}`);
    console.log(`📝 ${title}`);
    console.log('─'.repeat(60));
}

function printResults() {
    console.log('\n' + '═'.repeat(60));
    console.log('📊 FINAL TEST RESULTS');
    console.log('═'.repeat(60));
    console.log(`Total Tests: ${testResults.total}`);
    console.log(`✅ Passed: ${testResults.passed}`);
    console.log(`❌ Failed: ${testResults.failed}`);
    console.log(`Success Rate: ${((testResults.passed / testResults.total) * 100).toFixed(1)}%`);
    console.log('═'.repeat(60));
}

// ============================================================
// SOCKET CONNECTION
// ============================================================

function connectSockets() {
    return new Promise((resolve, reject) => {
        logSection('AUTHENTICATION & CONNECTION');
        
        let user1Connected = false;
        let user2Connected = false;
        
        // Connect User 1
        user1Socket = io(SERVER_URL, {
            auth: { token: USER1_TOKEN },
            transports: ['websocket'],
            reconnection: false
        });
        
        // Connect User 2
        user2Socket = io(SERVER_URL, {
            auth: { token: USER2_TOKEN },
            transports: ['websocket'],
            reconnection: false
        });
        
        // User 1 handlers
        user1Socket.on('connect', () => {
            console.log('🔌 User1 connected:', user1Socket.id);
        });
        
        user1Socket.on('authenticated', (data) => {
            user1Id = data.userId;
            console.log(`✅ User1 authenticated: ${data.username} (${user1Id})`);
            logTest('AUTH', 'User1 Authentication', 'PASS', `ID: ${user1Id}`);
            user1Connected = true;
            if (user2Connected) resolve();
        });
        
        // User 2 handlers
        user2Socket.on('connect', () => {
            console.log('🔌 User2 connected:', user2Socket.id);
        });
        
        user2Socket.on('authenticated', (data) => {
            user2Id = data.userId;
            console.log(`✅ User2 authenticated: ${data.username} (${user2Id})`);
            logTest('AUTH', 'User2 Authentication', 'PASS', `ID: ${user2Id}`);
            user2Connected = true;
            if (user1Connected) resolve();
        });
        
        // Error handlers
        user1Socket.on('error', (error) => {
            console.error('❌ User1 socket error:', error);
            logTest('AUTH', 'User1 Connection', 'FAIL', error.message);
            reject(error);
        });
        
        user2Socket.on('error', (error) => {
            console.error('❌ User2 socket error:', error);
            logTest('AUTH', 'User2 Connection', 'FAIL', error.message);
            reject(error);
        });
        
        // Timeout
        setTimeout(() => {
            if (!user1Connected || !user2Connected) {
                reject(new Error('Authentication timeout'));
            }
        }, 10000);
    });
}

// ============================================================
// TEST: MESSAGING
// ============================================================

function testMessaging() {
    return new Promise((resolve) => {
        logSection('MESSAGING TESTS');
        
        let messageReceived = false;
        let messageSent = false;
        
        // User2 listens for incoming message
        user2Socket.once('message:new', (data) => {
            messageReceived = true;
            logTest('MESSAGE', 'Receive Message', 'PASS', `From User1: ${data.message.content}`);
            if (messageSent) resolve();
        });
        
        // User1 sends message
        user1Socket.once('message:sent', (data) => {
            messageSent = true;
            logTest('MESSAGE', 'Send Message', 'PASS', `Message ID: ${data.message._id}`);
            if (messageReceived) resolve();
        });
        
        // Send message about the post
        setTimeout(() => {
            user1Socket.emit('message:send', {
                receiverId: user2Id,
                content: 'Test message about the post',
                postId: POST_ID,
                postType: 'marketplace',
                isFirstMessage: false
            });
        }, 500);
        
        setTimeout(() => {
            if (!messageReceived || !messageSent) {
                logTest('MESSAGE', 'Message Flow', 'FAIL', 'Timeout');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST: COMMENTS
// ============================================================

function testComments() {
    return new Promise((resolve) => {
        logSection('COMMENT TESTS');
        
        let commentCreated = false;
        let commentReceived = false;
        
        // First, join the room
        user1Socket.emit('room:join', {
            roomType: 'Post',
            roomId: POST_ID
        });
        
        user2Socket.emit('room:join', {
            roomType: 'Post',
            roomId: POST_ID
        });
        
        // Wait for room join
        setTimeout(() => {
            // User2 listens for new comment
            user2Socket.once('comment:new', (data) => {
                commentReceived = true;
                logTest('COMMENT', 'Receive Comment', 'PASS', `Content: ${data.comment.content}`);
                if (commentCreated) resolve();
            });
            
            // User1 creates comment
            user1Socket.once('comment:created', (data) => {
                commentCreated = true;
                logTest('COMMENT', 'Create Comment', 'PASS', `ID: ${data.comment._id}`);
                if (commentReceived) resolve();
            });
            
            // Create comment
            user1Socket.emit('comment:create', {
                targetType: 'Post',
                targetId: POST_ID,
                content: 'This is a test comment from comprehensive test',
                parentId: null
            });
        }, 1000);
        
        setTimeout(() => {
            if (!commentCreated) {
                logTest('COMMENT', 'Create Comment', 'FAIL', 'Timeout');
            }
            if (!commentReceived) {
                logTest('COMMENT', 'Receive Comment', 'FAIL', 'Timeout');
            }
            resolve();
        }, 8000);
    });
}

// ============================================================
// TEST: NOTIFICATIONS
// ============================================================

function testNotifications() {
    return new Promise((resolve) => {
        logSection('NOTIFICATION TESTS');
        
        let notificationSent = false;
        
        // User1 sends notification
        user1Socket.once('notification:sent', (data) => {
            notificationSent = true;
            logTest('NOTIFICATION', 'Send Post Like Notification', 'PASS', `Type: ${data.type}`);
            resolve();
        });
        
        // Send post like notification
        setTimeout(() => {
            user1Socket.emit('notification:post:like', {
                postOwnerId: user2Id,
                post: {
                    id: POST_ID,
                    title: 'Test Post'
                },
                liker: {
                    id: user1Id,
                    username: 'tigist',
                    displayName: 'Tigist User'
                }
            });
        }, 500);
        
        setTimeout(() => {
            if (!notificationSent) {
                logTest('NOTIFICATION', 'Send Post Like Notification', 'FAIL', 'Timeout');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST: LIKES (MATCHMAKING)
// ============================================================

function testLikes() {
    return new Promise((resolve) => {
        logSection('LIKE & MATCHMAKING TESTS');
        
        let likeCreated = false;
        let matchReceived = false;
        
        // User1 listens for match
        user1Socket.once('match:new', (data) => {
            matchReceived = true;
            logTest('LIKE', 'Mutual Match Notification', 'PASS', `Matched with: ${data.matchedUserId}`);
            if (likeCreated) resolve();
        });
        
        // User1 creates like
        user1Socket.once('like:created', (data) => {
            likeCreated = true;
            const status = data.isMutual ? 'Mutual Match!' : 'Like Created';
            logTest('LIKE', 'Create Like', 'PASS', status);
            if (data.isMutual && matchReceived) resolve();
            if (!data.isMutual) resolve();
        });
        
        // Create like
        setTimeout(() => {
            user1Socket.emit('like:create', {
                likedId: user2Id,
                status: 'like'
            });
        }, 500);
        
        setTimeout(() => {
            if (!likeCreated) {
                logTest('LIKE', 'Create Like', 'FAIL', 'Timeout');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST: FAVORITES
// ============================================================

function testFavorites() {
    return new Promise((resolve) => {
        logSection('FAVORITE TESTS');
        
        let favoriteAdded = false;
        
        // User1 adds favorite
        user1Socket.once('favorite:added', (data) => {
            favoriteAdded = true;
            logTest('FAVORITE', 'Add Favorite', 'PASS', `Target: ${data.favorite.targetType} ${data.favorite.targetId}`);
            resolve();
        });
        
        // Add favorite
        setTimeout(() => {
            user1Socket.emit('favorite:add', {
                targetType: 'Post',
                targetId: POST_ID
            });
        }, 500);
        
        setTimeout(() => {
            if (!favoriteAdded) {
                logTest('FAVORITE', 'Add Favorite', 'FAIL', 'Timeout or already exists');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST: USER STATUS
// ============================================================

function testUserStatus() {
    return new Promise((resolve) => {
        logSection('USER STATUS TESTS');
        
        let statusUpdated = false;
        let statusChanged = false;
        
        // Listen for status change broadcast
        user2Socket.once('user:status:changed', (data) => {
            if (data.userId === user1Id) {
                statusChanged = true;
                logTest('STATUS', 'Status Change Broadcast', 'PASS', `User ${data.userId} -> ${data.status}`);
                if (statusUpdated) resolve();
            }
        });
        
        // User1 updates status
        user1Socket.once('user:status:updated', (data) => {
            statusUpdated = true;
            logTest('STATUS', 'Update Status', 'PASS', `New status: ${data.status}`);
            if (statusChanged) resolve();
        });
        
        // Update status
        setTimeout(() => {
            user1Socket.emit('user:status:update', {
                status: 'away'
            });
        }, 500);
        
        setTimeout(() => {
            if (!statusUpdated) {
                logTest('STATUS', 'Update Status', 'FAIL', 'Timeout');
            }
            if (!statusChanged) {
                logTest('STATUS', 'Status Change Broadcast', 'FAIL', 'Not received');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST: TYPING INDICATORS
// ============================================================

function testTypingIndicators() {
    return new Promise((resolve) => {
        logSection('TYPING INDICATOR TESTS');
        
        let typingReceived = false;
        let typingStopReceived = false;
        
        // User2 listens for typing
        user2Socket.once('message:typing', (data) => {
            typingReceived = true;
            logTest('TYPING', 'Typing Start', 'PASS', `User ${data.userId} is typing`);
            if (typingStopReceived) resolve();
        });
        
        user2Socket.once('message:typing:stop', (data) => {
            typingStopReceived = true;
            logTest('TYPING', 'Typing Stop', 'PASS', `User ${data.userId} stopped typing`);
            if (typingReceived) resolve();
        });
        
        // User1 starts typing
        setTimeout(() => {
            user1Socket.emit('message:typing:start', {
                receiverId: user2Id
            });
        }, 500);
        
        // User1 stops typing
        setTimeout(() => {
            user1Socket.emit('message:typing:stop', {
                receiverId: user2Id
            });
        }, 1500);
        
        setTimeout(() => {
            if (!typingReceived) {
                logTest('TYPING', 'Typing Start', 'FAIL', 'Not received');
            }
            if (!typingStopReceived) {
                logTest('TYPING', 'Typing Stop', 'FAIL', 'Not received');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// MAIN TEST RUNNER
// ============================================================

async function runAllTests() {
    try {
        // Connect and authenticate
        await connectSockets();
        
        // Run tests sequentially
        await testMessaging();
        await testComments();
        await testNotifications();
        await testLikes();
        await testFavorites();
        await testUserStatus();
        await testTypingIndicators();
        
        // Print results
        printResults();
        
        // Cleanup
        user1Socket.disconnect();
        user2Socket.disconnect();
        
        // Exit with appropriate code
        process.exit(testResults.failed === 0 ? 0 : 1);
        
    } catch (error) {
        console.error('\n❌ Test suite failed:', error.message);
        printResults();
        process.exit(1);
    }
}

// Start tests
runAllTests();
