// Simple notification test
const io = require('socket.io-client');

const user1Token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjIzMjc4NzQsImV4cCI6MTc2MjMyODc3NH0.RQtWW83Wi9hW7I8FfFUnASR_jDOfiF-ooi3gXO_tStY';

const user2Token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJhOThhZTFjLTg2YzktNGY5ZS1iOWQ2LTQ1MjE2NzMzNDQ4OSIsInVzZXJuYW1lIjoiYWJlbCIsImVtYWlsIjoiYWJlbEBnbWFpbC5jb20iLCJwaG9uZSI6IisyNTE5MTExMTExMTEiLCJhdXRoUHJvdmlkZXIiOiJwYXNzd29yZCIsImlzVmVyaWZpZWQiOmZhbHNlLCJzdGF0dXMiOiJhY3RpdmUiLCJyb2xlcyI6WyJkb2N0b3IiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6IkpvaG4gRG9lIiwicHJvZmVzc2lvbiI6IlNvZnR3YXJlIERldmVsb3BlciIsInZlcmlmaWNhdGlvblN0YXR1cyI6InByb2Zlc3Npb25hbCIsInBob3RvVXJsIjpudWxsLCJiaW8iOiJTb2Z0d2FyZSBFbmdpbmVlciB3aXRoIDUgeWVhcnMgZXhwZXJpZW5jZSJ9LCJpYXQiOjE3NjIzMjc4MzAsImV4cCI6MTc2MjMyODczMH0.Yb9wBuowK9LukpF6g5fnH7so-J22UkFHSWQqn-71REM';

console.log('🧪 NOTIFICATION TEST\n');

let testsCompleted = 0;
const totalTests = 3;

// User 1 (Liker/Commenter)
const user1Socket = io('http://localhost:5000', {
    auth: { token: user1Token },
    transports: ['websocket'],
    reconnection: false
});

// User 2 (Post Owner)
const user2Socket = io('http://localhost:5000', {
    auth: { token: user2Token },
    transports: ['websocket'],
    reconnection: false
});

user1Socket.on('connect', () => {
    console.log('✅ User1 (tigist) connected');
});

user2Socket.on('connect', () => {
    console.log('✅ User2 (abel) connected');
});

user1Socket.on('auth:success', (data) => {
    console.log(`✅ User1 authenticated: ${data.user.username}\n`);
});

user2Socket.on('auth:success', (data) => {
    console.log(`✅ User2 authenticated: ${data.user.username}\n`);
    
    // Start tests after both users are authenticated
    setTimeout(() => {
        runTests();
    }, 1000);
});

function runTests() {
    console.log('📝 Starting notification tests...\n');
    
    // Test 1: Post Like Notification
    testPostLikeNotification();
    
    // Test 2: Post Comment Notification
    setTimeout(() => {
        testPostCommentNotification();
    }, 2000);
    
    // Test 3: Comment Reply Notification
    setTimeout(() => {
        testCommentReplyNotification();
    }, 4000);
}

function testPostLikeNotification() {
    console.log('📝 Test 1: Post Like Notification');
    
    user1Socket.once('notification:sent', (data) => {
        console.log('✅ Like notification sent');
        console.log(`   Type: ${data.type}`);
        testsCompleted++;
        checkCompletion();
    });
    
    user1Socket.emit('notification:post:like', {
        postOwnerId: 'ba98ae1c-86c9-4f9e-b9d6-452167334489',
        post: {
            id: '1eb3a0b2-f1ff-417d-bf65-a6dda5329427',
            title: 'Test Post'
        },
        liker: {
            id: '09a08a5d-fd36-46c0-8974-8ce8489931f9',
            username: 'tigist',
            displayName: 'Tigist'
        }
    });
}

function testPostCommentNotification() {
    console.log('\n📝 Test 2: Post Comment Notification');
    
    user1Socket.once('notification:sent', (data) => {
        console.log('✅ Comment notification sent');
        console.log(`   Type: ${data.type}`);
        testsCompleted++;
        checkCompletion();
    });
    
    user1Socket.emit('notification:post:comment', {
        postOwnerId: 'ba98ae1c-86c9-4f9e-b9d6-452167334489',
        post: {
            id: '1eb3a0b2-f1ff-417d-bf65-a6dda5329427',
            title: 'Test Post'
        },
        comment: {
            id: 'test-comment-id',
            content: 'Great post!'
        },
        commenter: {
            id: '09a08a5d-fd36-46c0-8974-8ce8489931f9',
            username: 'tigist',
            displayName: 'Tigist'
        }
    });
}

function testCommentReplyNotification() {
    console.log('\n📝 Test 3: Comment Reply Notification');
    
    user2Socket.once('notification:sent', (data) => {
        console.log('✅ Reply notification sent');
        console.log(`   Type: ${data.type}`);
        testsCompleted++;
        checkCompletion();
    });
    
    user2Socket.emit('notification:comment:reply', {
        commentOwnerId: '09a08a5d-fd36-46c0-8974-8ce8489931f9',
        comment: {
            id: 'test-comment-id',
            content: 'Great post!'
        },
        reply: {
            id: 'test-reply-id',
            content: 'Thank you!'
        },
        replier: {
            id: 'ba98ae1c-86c9-4f9e-b9d6-452167334489',
            username: 'abel',
            displayName: 'Abel'
        }
    });
}

function checkCompletion() {
    if (testsCompleted === totalTests) {
        console.log('\n' + '='.repeat(60));
        console.log('📊 TEST RESULTS');
        console.log('='.repeat(60));
        console.log(`✅ All ${totalTests} notification tests passed!`);
        console.log('Success Rate: 100%');
        console.log('='.repeat(60));
        
        user1Socket.disconnect();
        user2Socket.disconnect();
        process.exit(0);
    }
}

// Error handlers
user1Socket.on('error', (error) => {
    console.error('❌ User1 error:', error.message || error);
});

user2Socket.on('error', (error) => {
    console.error('❌ User2 error:', error.message || error);
});

user1Socket.on('connect_error', (error) => {
    console.error('❌ User1 connection error:', error.message);
    process.exit(1);
});

user2Socket.on('connect_error', (error) => {
    console.error('❌ User2 connection error:', error.message);
    process.exit(1);
});

// Timeout
setTimeout(() => {
    console.error('\n❌ Test timeout');
    console.log(`Completed: ${testsCompleted}/${totalTests} tests`);
    process.exit(1);
}, 15000);
