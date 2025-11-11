/**
 * Socket Comments & Notifications Test Script
 * Tests comment creation, updates, deletion and notification system
 * 
 * Usage:
 * node test/socket-comments-notifications-test.js
 */

const io = require('socket.io-client');

// ============================================================
// CONFIGURATION
// ============================================================

const CONFIG = {
    serverUrl: 'https://ethiopostservice.garamuletaapartment.com',
    
    // User 1 (Commenter - tigist)
    user1: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjIzMjc4NzQsImV4cCI6MTc2MjMyODc3NH0.RQtWW83Wi9hW7I8FfFUnASR_jDOfiF-ooi3gXO_tStY',
        userId: '09a08a5d-fd36-46c0-8974-8ce8489931f9',
        username: 'tigist'
    },
    
    // User 2 (Post Owner - abel)
    user2: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJhOThhZTFjLTg2YzktNGY5ZS1iOWQ2LTQ1MjE2NzMzNDQ4OSIsInVzZXJuYW1lIjoiYWJlbCIsImVtYWlsIjoiYWJlbEBnbWFpbC5jb20iLCJwaG9uZSI6IisyNTE5MTExMTExMTEiLCJhdXRoUHJvdmlkZXIiOiJwYXNzd29yZCIsImlzVmVyaWZpZWQiOmZhbHNlLCJzdGF0dXMiOiJhY3RpdmUiLCJyb2xlcyI6WyJkb2N0b3IiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6IkpvaG4gRG9lIiwicHJvZmVzc2lvbiI6IlNvZnR3YXJlIERldmVsb3BlciIsInZlcmlmaWNhdGlvblN0YXR1cyI6InByb2Zlc3Npb25hbCIsInBob3RvVXJsIjpudWxsLCJiaW8iOiJTb2Z0d2FyZSBFbmdpbmVlciB3aXRoIDUgeWVhcnMgZXhwZXJpZW5jZSJ9LCJpYXQiOjE3NjIzMjc4MzAsImV4cCI6MTc2MjMyODczMH0.Yb9wBuowK9LukpF6g5fnH7so-J22UkFHSWQqn-71REM',
        userId: 'ba98ae1c-86c9-4f9e-b9d6-452167334489',
        username: 'abel'
    },
    
    // Test Post
    post: {
        id: '1eb3a0b2-f1ff-417d-bf65-a6dda5329427',
        type: 'Post'
    }
};

// ============================================================
// TEST UTILITIES
// ============================================================

let testResults = [];
let testNumber = 0;
let createdCommentId = null;

function log(message, type = 'info') {
    const colors = {
        info: '\x1b[36m',
        success: '\x1b[32m',
        error: '\x1b[31m',
        warning: '\x1b[33m',
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

let user1Socket = null;
let user2Socket = null;

function createSocket(name, token) {
    log(`\n🔌 Connecting ${name}...`, 'info');
    
    const socket = io(CONFIG.serverUrl, {
        auth: { token },
        transports: ['websocket'],
        reconnection: false
    });
    
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
    log('🧪 COMMENTS & NOTIFICATIONS TEST SUITE', 'info');
    log('='.repeat(60), 'info');
    
    try {
        // Test 1: Authentication
        await testAuthentication();
        await wait(1000);
        
        // Test 2: Join room
        await testJoinRoom();
        await wait(1000);
        
        // Test 3: Create comment
        await testCreateComment();
        await wait(1000);
        
        // Test 4: Comment typing indicators
        await testCommentTyping();
        await wait(1000);
        
        // Test 5: Update comment
        await testUpdateComment();
        await wait(1000);
        
        // Test 6: Post like notification
        await testPostLikeNotification();
        await wait(1000);
        
        // Test 7: Post comment notification
        await testPostCommentNotification();
        await wait(1000);
        
        // Test 8: Comment reply notification
        await testCommentReplyNotification();
        await wait(1000);
        
        // Test 9: Delete comment
        await testDeleteComment();
        await wait(1000);
        
        // Print results
        printResults();
        
    } catch (error) {
        log(`\n❌ Test suite failed: ${error.message}`, 'error');
        console.error(error);
    } finally {
        // Cleanup
        if (user1Socket) user1Socket.disconnect();
        if (user2Socket) user2Socket.disconnect();
        process.exit(0);
    }
}

// ============================================================
// TEST 1: AUTHENTICATION
// ============================================================

async function testAuthentication() {
    log('\n📝 Test 1: Authentication', 'info');
    
    return new Promise((resolve, reject) => {
        let user1Auth = false;
        let user2Auth = false;
        
        user1Socket = createSocket('USER1', CONFIG.user1.token);
        
        user1Socket.on('auth:success', (data) => {
            CONFIG.user1.userId = data.user.id;
            log(`User1 authenticated: ${data.user.username}`, 'success');
            user1Auth = true;
            
            if (user2Auth) {
                logTest('Authentication', 'PASS', 'Both users authenticated');
                resolve();
            }
        });
        
        user2Socket = createSocket('USER2', CONFIG.user2.token);
        
        user2Socket.on('auth:success', (data) => {
            CONFIG.user2.userId = data.user.id;
            log(`User2 authenticated: ${data.user.username}`, 'success');
            user2Auth = true;
            
            if (user1Auth) {
                logTest('Authentication', 'PASS', 'Both users authenticated');
                resolve();
            }
        });
        
        setTimeout(() => {
            if (!user1Auth || !user2Auth) {
                logTest('Authentication', 'FAIL', 'Timeout waiting for auth');
                reject(new Error('Authentication timeout'));
            }
        }, 5000);
    });
}

// ============================================================
// TEST 2: JOIN ROOM
// ============================================================

async function testJoinRoom() {
    log('\n📝 Test 2: Join room', 'info');
    
    return new Promise((resolve) => {
        let user1Joined = false;
        let user2Joined = false;
        
        user1Socket.once('room:joined', (data) => {
            log(`User1 joined room: ${data.room}`, 'success');
            user1Joined = true;
            
            if (user2Joined) {
                logTest('Join Room', 'PASS', 'Both users joined room');
                resolve();
            }
        });
        
        user2Socket.once('room:joined', (data) => {
            log(`User2 joined room: ${data.room}`, 'success');
            user2Joined = true;
            
            if (user1Joined) {
                logTest('Join Room', 'PASS', 'Both users joined room');
                resolve();
            }
        });
        
        log(`Joining room: ${CONFIG.post.type}:${CONFIG.post.id}`, 'info');
        user1Socket.emit('room:join', {
            roomType: CONFIG.post.type,
            roomId: CONFIG.post.id
        });
        
        user2Socket.emit('room:join', {
            roomType: CONFIG.post.type,
            roomId: CONFIG.post.id
        });
        
        setTimeout(() => {
            if (!user1Joined || !user2Joined) {
                logTest('Join Room', 'FAIL', 'Timeout waiting for room join');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST 3: CREATE COMMENT
// ============================================================

async function testCreateComment() {
    log('\n📝 Test 3: Create comment', 'info');
    
    return new Promise((resolve) => {
        let commentCreated = false;
        let commentReceived = false;
        
        // User2 listens for new comment
        user2Socket.once('comment:new', (data) => {
            log(`✅ User2 received new comment`, 'success');
            log(`Content: ${data.comment.content}`, 'info');
            commentReceived = true;
            
            if (commentCreated) {
                logTest('Receive Comment', 'PASS', 'Comment received in real-time');
                resolve();
            }
        });
        
        // User1 creates comment
        user1Socket.once('comment:created', (data) => {
            log(`✅ Comment created`, 'success');
            log(`Comment ID: ${data.comment._id}`, 'info');
            createdCommentId = data.comment._id;
            commentCreated = true;
            
            logTest('Create Comment', 'PASS', `Comment ID: ${data.comment._id}`);
            
            setTimeout(() => {
                if (!commentReceived) {
                    logTest('Receive Comment', 'FAIL', 'User2 did not receive comment');
                }
                resolve();
            }, 2000);
        });
        
        log(`User1 creating comment on post ${CONFIG.post.id}...`, 'info');
        user1Socket.emit('comment:create', {
            targetType: CONFIG.post.type,
            targetId: CONFIG.post.id,
            content: 'Great post! Very informative.',
            parentId: null
        });
        
        setTimeout(() => {
            if (!commentCreated) {
                logTest('Create Comment', 'FAIL', 'Timeout - comment not created');
            }
            if (!commentReceived) {
                logTest('Receive Comment', 'FAIL', 'Timeout - comment not received');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST 4: COMMENT TYPING INDICATORS
// ============================================================

async function testCommentTyping() {
    log('\n📝 Test 4: Comment typing indicators', 'info');
    
    return new Promise((resolve) => {
        let typingReceived = false;
        let typingStopReceived = false;
        
        user2Socket.once('comment:typing', (data) => {
            log(`User2 sees User1 typing`, 'success');
            log(`User: ${data.username}`, 'info');
            typingReceived = true;
            
            if (typingStopReceived) {
                logTest('Comment Typing', 'PASS', 'Both typing events received');
                resolve();
            }
        });
        
        user2Socket.once('comment:typing:stop', (data) => {
            log(`User2 sees User1 stopped typing`, 'success');
            typingStopReceived = true;
            
            if (typingReceived) {
                logTest('Comment Typing', 'PASS', 'Both typing events received');
                resolve();
            }
        });
        
        log(`User1 starts typing...`, 'info');
        user1Socket.emit('comment:typing:start', {
            targetType: CONFIG.post.type,
            targetId: CONFIG.post.id
        });
        
        setTimeout(() => {
            log(`User1 stops typing...`, 'info');
            user1Socket.emit('comment:typing:stop', {
                targetType: CONFIG.post.type,
                targetId: CONFIG.post.id
            });
        }, 1000);
        
        setTimeout(() => {
            if (!typingReceived || !typingStopReceived) {
                logTest('Comment Typing', 'FAIL', 'Did not receive all typing events');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST 5: UPDATE COMMENT
// ============================================================

async function testUpdateComment() {
    log('\n📝 Test 5: Update comment', 'info');
    
    if (!createdCommentId) {
        logTest('Update Comment', 'SKIP', 'No comment to update');
        return;
    }
    
    return new Promise((resolve) => {
        let commentUpdated = false;
        let updateReceived = false;
        
        user2Socket.once('comment:updated', (data) => {
            log(`✅ User2 received comment update`, 'success');
            log(`New content: ${data.comment.content}`, 'info');
            updateReceived = true;
            
            if (commentUpdated) {
                logTest('Receive Update', 'PASS', 'Update received in real-time');
                resolve();
            }
        });
        
        user1Socket.once('comment:update:success', (data) => {
            log(`✅ Comment updated`, 'success');
            commentUpdated = true;
            
            logTest('Update Comment', 'PASS', 'Comment updated successfully');
            
            setTimeout(() => {
                if (!updateReceived) {
                    logTest('Receive Update', 'FAIL', 'User2 did not receive update');
                }
                resolve();
            }, 2000);
        });
        
        log(`User1 updating comment ${createdCommentId}...`, 'info');
        user1Socket.emit('comment:update', {
            commentId: createdCommentId,
            content: 'Great post! Very informative. [EDITED]'
        });
        
        setTimeout(() => {
            if (!commentUpdated) {
                logTest('Update Comment', 'FAIL', 'Timeout - comment not updated');
            }
            if (!updateReceived) {
                logTest('Receive Update', 'FAIL', 'Timeout - update not received');
            }
            resolve();
        }, 5000);
    });
}

// ============================================================
// TEST 6: POST LIKE NOTIFICATION
// ============================================================

async function testPostLikeNotification() {
    log('\n📝 Test 6: Post like notification', 'info');
    
    return new Promise((resolve) => {
        let resolved = false;
        
        user1Socket.once('notification:sent', (data) => {
            if (resolved) return;
            resolved = true;
            
            log(`✅ Like notification sent`, 'success');
            log(`Type: ${data.type}`, 'info');
            
            logTest('Post Like Notification', 'PASS', 'Notification sent');
            resolve();
        });
        
        log(`User1 sending like notification...`, 'info');
        user1Socket.emit('notification:post:like', {
            postId: CONFIG.post.id,
            postOwnerId: CONFIG.user2.userId
        });
        
        setTimeout(() => {
            if (!resolved) {
                resolved = true;
                logTest('Post Like Notification', 'FAIL', 'Timeout - notification not sent');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST 7: POST COMMENT NOTIFICATION
// ============================================================

async function testPostCommentNotification() {
    log('\n📝 Test 7: Post comment notification', 'info');
    
    return new Promise((resolve) => {
        let resolved = false;
        
        user1Socket.once('notification:sent', (data) => {
            if (resolved) return;
            resolved = true;
            
            log(`✅ Comment notification sent`, 'success');
            log(`Type: ${data.type}`, 'info');
            
            logTest('Post Comment Notification', 'PASS', 'Notification sent');
            resolve();
        });
        
        log(`User1 sending comment notification...`, 'info');
        user1Socket.emit('notification:post:comment', {
            postId: CONFIG.post.id,
            postOwnerId: CONFIG.user2.userId,
            commentId: createdCommentId || 'test-comment-id'
        });
        
        setTimeout(() => {
            if (!resolved) {
                resolved = true;
                logTest('Post Comment Notification', 'FAIL', 'Timeout - notification not sent');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST 8: COMMENT REPLY NOTIFICATION
// ============================================================

async function testCommentReplyNotification() {
    log('\n📝 Test 8: Comment reply notification', 'info');
    
    return new Promise((resolve) => {
        let resolved = false;
        
        user2Socket.once('notification:sent', (data) => {
            if (resolved) return;
            resolved = true;
            
            log(`✅ Reply notification sent`, 'success');
            log(`Type: ${data.type}`, 'info');
            
            logTest('Comment Reply Notification', 'PASS', 'Notification sent');
            resolve();
        });
        
        log(`User2 sending reply notification...`, 'info');
        user2Socket.emit('notification:comment:reply', {
            commentId: createdCommentId || 'test-comment-id',
            parentCommentOwnerId: CONFIG.user1.userId,
            replyId: 'test-reply-id'
        });
        
        setTimeout(() => {
            if (!resolved) {
                resolved = true;
                logTest('Comment Reply Notification', 'FAIL', 'Timeout - notification not sent');
                resolve();
            }
        }, 5000);
    });
}

// ============================================================
// TEST 9: DELETE COMMENT
// ============================================================

async function testDeleteComment() {
    log('\n📝 Test 9: Delete comment', 'info');
    
    if (!createdCommentId) {
        logTest('Delete Comment', 'SKIP', 'No comment to delete');
        return;
    }
    
    return new Promise((resolve) => {
        let commentDeleted = false;
        let deleteReceived = false;
        
        user2Socket.once('comment:deleted', (data) => {
            log(`✅ User2 received comment deletion`, 'success');
            log(`Deleted comment ID: ${data.commentId}`, 'info');
            deleteReceived = true;
            
            if (commentDeleted) {
                logTest('Receive Deletion', 'PASS', 'Deletion received in real-time');
                resolve();
            }
        });
        
        user1Socket.once('comment:delete:success', (data) => {
            log(`✅ Comment deleted`, 'success');
            commentDeleted = true;
            
            logTest('Delete Comment', 'PASS', 'Comment deleted successfully');
            
            setTimeout(() => {
                if (!deleteReceived) {
                    logTest('Receive Deletion', 'FAIL', 'User2 did not receive deletion');
                }
                resolve();
            }, 2000);
        });
        
        log(`User1 deleting comment ${createdCommentId}...`, 'info');
        user1Socket.emit('comment:delete', {
            commentId: createdCommentId
        });
        
        setTimeout(() => {
            if (!commentDeleted) {
                logTest('Delete Comment', 'FAIL', 'Timeout - comment not deleted');
            }
            if (!deleteReceived) {
                logTest('Receive Deletion', 'FAIL', 'Timeout - deletion not received');
            }
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

runTests().catch(error => {
    log(`\n❌ Fatal error: ${error.message}`, 'error');
    console.error(error);
    process.exit(1);
});
