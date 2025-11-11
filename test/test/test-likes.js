// Test likes functionality
const io = require('socket.io-client');

const user1Token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjIzMjc4NzQsImV4cCI6MTc2MjMyODc3NH0.RQtWW83Wi9hW7I8FfFUnASR_jDOfiF-ooi3gXO_tStY';

const user2Token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJhOThhZTFjLTg2YzktNGY5ZS1iOWQ2LTQ1MjE2NzMzNDQ4OSIsInVzZXJuYW1lIjoiYWJlbCIsImVtYWlsIjoiYWJlbEBnbWFpbC5jb20iLCJwaG9uZSI6IisyNTE5MTExMTExMTEiLCJhdXRoUHJvdmlkZXIiOiJwYXNzd29yZCIsImlzVmVyaWZpZWQiOmZhbHNlLCJzdGF0dXMiOiJhY3RpdmUiLCJyb2xlcyI6WyJkb2N0b3IiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6IkpvaG4gRG9lIiwicHJvZmVzc2lvbiI6IlNvZnR3YXJlIERldmVsb3BlciIsInZlcmlmaWNhdGlvblN0YXR1cyI6InByb2Zlc3Npb25hbCIsInBob3RvVXJsIjpudWxsLCJiaW8iOiJTb2Z0d2FyZSBFbmdpbmVlciB3aXRoIDUgeWVhcnMgZXhwZXJpZW5jZSJ9LCJpYXQiOjE3NjIzMjc4MzAsImV4cCI6MTc2MjMyODczMH0.Yb9wBuowK9LukpF6g5fnH7so-J22UkFHSWQqn-71REM';

console.log('🧪 LIKES & MATCHMAKING TEST\n');

let testsCompleted = 0;
const totalTests = 5;
let user1Id, user2Id;

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

// Get user IDs from authenticated event
let user1Ready = false;
let user2Ready = false;

user1Socket.on('authenticated', (data) => {
    user1Id = data.userId;
    console.log(`✅ User1 (tigist) ID: ${user1Id}`);
    user1Ready = true;
    if (user2Ready) {
        setTimeout(() => runTests(), 1000);
    }
});

user2Socket.on('authenticated', (data) => {
    user2Id = data.userId;
    console.log(`✅ User2 (abel) ID: ${user2Id}\n`);
    user2Ready = true;
    if (user1Ready) {
        setTimeout(() => runTests(), 1000);
    }
});

function runTests() {
    console.log('📝 Starting like tests...\n');
    
    // Test 1: User1 likes User2
    testCreateLike();
    
    // Test 2: Check like status
    setTimeout(() => {
        testGetLikeStatus();
    }, 1500);
    
    // Test 3: User2 likes User1 back (mutual match)
    setTimeout(() => {
        testMutualLike();
    }, 3000);
    
    // Test 4: Get matches
    setTimeout(() => {
        testGetMatches();
    }, 4500);
    
    // Test 5: Unlike
    setTimeout(() => {
        testUnlike();
    }, 6000);
}

function testCreateLike() {
    console.log('📝 Test 1: User1 likes User2');
    
    user1Socket.once('like:created', (data) => {
        console.log('✅ Like created');
        console.log(`   Liker: ${data.like.likerId}`);
        console.log(`   Liked: ${data.like.likedId}`);
        console.log(`   Is Mutual: ${data.isMutual}`);
        testsCompleted++;
    });
    
    user2Socket.once('like:received', (data) => {
        console.log('✅ User2 received like notification');
        console.log(`   From: ${data.likerId}`);
    });
    
    user1Socket.emit('like:create', {
        likedId: user2Id
    });
}

function testGetLikeStatus() {
    console.log('\n📝 Test 2: Check like status');
    
    user1Socket.once('like:status', (data) => {
        console.log('✅ Like status retrieved');
        console.log(`   User liked: ${data.status.userLiked}`);
        console.log(`   Other user liked: ${data.status.otherUserLiked}`);
        console.log(`   Is Mutual: ${data.status.isMutual}`);
        testsCompleted++;
    });
    
    user1Socket.emit('like:status:get', {
        userId: user2Id
    });
}

function testMutualLike() {
    console.log('\n📝 Test 3: User2 likes User1 back (mutual match)');
    
    user2Socket.once('like:created', (data) => {
        console.log('✅ Like created');
        console.log(`   Is Mutual: ${data.isMutual}`);
    });
    
    user1Socket.once('match:new', (data) => {
        console.log('✅ User1 received match notification');
        console.log(`   Matched with: ${data.matchedUserId}`);
        testsCompleted++;
    });
    
    user2Socket.once('match:new', (data) => {
        console.log('✅ User2 received match notification');
        console.log(`   Matched with: ${data.matchedUserId}`);
    });
    
    user2Socket.emit('like:create', {
        likedId: user1Id
    });
}

function testGetMatches() {
    console.log('\n📝 Test 4: Get mutual matches');
    
    user1Socket.once('matches:list', (data) => {
        console.log('✅ Matches retrieved');
        console.log(`   Total matches: ${data.pagination.total}`);
        testsCompleted++;
    });
    
    user1Socket.emit('matches:get', {
        page: 1,
        limit: 20
    });
}

function testUnlike() {
    console.log('\n📝 Test 5: Unlike user');
    
    user1Socket.once('like:removed', (data) => {
        console.log('✅ Like removed');
        console.log(`   Unliked: ${data.likedId}`);
        testsCompleted++;
        checkCompletion();
    });
    
    user1Socket.emit('like:remove', {
        likedId: user2Id
    });
}

function checkCompletion() {
    if (testsCompleted === totalTests) {
        console.log('\n' + '='.repeat(60));
        console.log('📊 TEST RESULTS');
        console.log('='.repeat(60));
        console.log(`✅ All ${totalTests} like tests passed!`);
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
