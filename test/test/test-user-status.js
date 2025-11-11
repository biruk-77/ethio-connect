// Test user status functionality
const io = require('socket.io-client');

const user1Token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjIzMjc4NzQsImV4cCI6MTc2MjMyODc3NH0.RQtWW83Wi9hW7I8FfFUnASR_jDOfiF-ooi3gXO_tStY';

const user2Token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJhOThhZTFjLTg2YzktNGY5ZS1iOWQ2LTQ1MjE2NzMzNDQ4OSIsInVzZXJuYW1lIjoiYWJlbCIsImVtYWlsIjoiYWJlbEBnbWFpbC5jb20iLCJwaG9uZSI6IisyNTE5MTExMTExMTEiLCJhdXRoUHJvdmlkZXIiOiJwYXNzd29yZCIsImlzVmVyaWZpZWQiOmZhbHNlLCJzdGF0dXMiOiJhY3RpdmUiLCJyb2xlcyI6WyJkb2N0b3IiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6IkpvaG4gRG9lIiwicHJvZmVzc2lvbiI6IlNvZnR3YXJlIERldmVsb3BlciIsInZlcmlmaWNhdGlvblN0YXR1cyI6InByb2Zlc3Npb25hbCIsInBob3RvVXJsIjpudWxsLCJiaW8iOiJTb2Z0d2FyZSBFbmdpbmVlciB3aXRoIDUgeWVhcnMgZXhwZXJpZW5jZSJ9LCJpYXQiOjE3NjIzMjc4MzAsImV4cCI6MTc2MjMyODczMH0.Yb9wBuowK9LukpF6g5fnH7so-J22UkFHSWQqn-71REM';

console.log('🧪 USER STATUS TEST\n');

let testsCompleted = 0;
const totalTests = 4;

// User 1 (tigist)
const user1Socket = io('http://localhost:5000', {
    auth: { token: user1Token },
    transports: ['websocket'],
    reconnection: false
});

// User 2 (abel)
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

// Wait for both users to be online
let user1Online = false;
let user2Online = false;

user1Socket.on('user:online', (data) => {
    if (!user1Online && data.userId) {
        user1Online = true;
        console.log(`✅ User1 online: ${data.userId}`);
        if (user2Online) {
            setTimeout(() => runTests(), 1000);
        }
    }
});

user2Socket.on('user:online', (data) => {
    if (!user2Online && data.userId) {
        user2Online = true;
        console.log(`✅ User2 online: ${data.userId}`);
        if (user1Online) {
            setTimeout(() => runTests(), 1000);
        }
    }
});

// Listen for online/offline broadcasts
user1Socket.on('user:online', (data) => {
    console.log(`📢 User came online: ${data.userId}`);
});

user1Socket.on('user:offline', (data) => {
    console.log(`📢 User went offline: ${data.userId}`);
});

function runTests() {
    console.log('📝 Starting user status tests...\n');
    
    // Test 1: Get user status
    testGetUserStatus();
    
    // Test 2: Get multiple users' statuses
    setTimeout(() => {
        testGetUsersStatuses();
    }, 1500);
    
    // Test 3: Update user status
    setTimeout(() => {
        testUpdateUserStatus();
    }, 3000);
    
    // Test 4: User disconnect (offline)
    setTimeout(() => {
        testUserDisconnect();
    }, 4500);
}

function testGetUserStatus() {
    console.log('📝 Test 1: Get user status');
    
    user1Socket.once('user:status', (data) => {
        console.log('✅ User status retrieved');
        console.log(`   User ID: ${data.status.userId}`);
        console.log(`   Status: ${data.status.status}`);
        console.log(`   Last Seen: ${data.status.lastSeen}`);
        testsCompleted++;
    });
    
    user1Socket.emit('user:status:get', {
        userId: 'ba98ae1c-86c9-4f9e-b9d6-452167334489'
    });
}

function testGetUsersStatuses() {
    console.log('\n📝 Test 2: Get multiple users\' statuses');
    
    user1Socket.once('users:statuses', (data) => {
        console.log('✅ Users statuses retrieved');
        console.log(`   Count: ${data.statuses.length}`);
        data.statuses.forEach((status, index) => {
            console.log(`   User ${index + 1}: ${status.status}`);
        });
        testsCompleted++;
    });
    
    user1Socket.emit('users:statuses:get', {
        userIds: [
            '09a08a5d-fd36-46c0-8974-8ce8489931f9',
            'ba98ae1c-86c9-4f9e-b9d6-452167334489'
        ]
    });
}

function testUpdateUserStatus() {
    console.log('\n📝 Test 3: Update user status to away');
    
    user1Socket.once('user:status:updated', (data) => {
        console.log('✅ User status updated');
        console.log(`   New Status: ${data.status}`);
        testsCompleted++;
    });
    
    user1Socket.emit('user:status:update', {
        status: 'away'
    });
}

function testUserDisconnect() {
    console.log('\n📝 Test 4: User disconnect (goes offline)');
    
    user1Socket.once('user:offline', (data) => {
        console.log('✅ User offline notification received');
        console.log(`   User ID: ${data.userId}`);
        testsCompleted++;
        
        setTimeout(() => {
            checkCompletion();
        }, 500);
    });
    
    // Disconnect user2
    user2Socket.disconnect();
}

function checkCompletion() {
    if (testsCompleted === totalTests) {
        console.log('\n' + '='.repeat(60));
        console.log('📊 TEST RESULTS');
        console.log('='.repeat(60));
        console.log(`✅ All ${totalTests} user status tests passed!`);
        console.log('Success Rate: 100%');
        console.log('='.repeat(60));
        
        user1Socket.disconnect();
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
