// Test favorites functionality
const io = require('socket.io-client');

const userToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjIzMjc4NzQsImV4cCI6MTc2MjMyODc3NH0.RQtWW83Wi9hW7I8FfFUnASR_jDOfiF-ooi3gXO_tStY';

console.log('🧪 FAVORITES TEST\n');

let testsCompleted = 0;
const totalTests = 5;

const socket = io('http://localhost:5000', {
    auth: { token: userToken },
    transports: ['websocket'],
    reconnection: false
});

socket.on('connect', () => {
    console.log('✅ Connected');
});

socket.on('connect', () => {
    console.log('✅ Connected and authenticated\n');
    
    setTimeout(() => {
        runTests();
    }, 1000);
});

function runTests() {
    console.log('📝 Starting favorite tests...\n');
    
    // Test 1: Add favorite post
    testAddFavorite();
    
    // Test 2: Check if favorited
    setTimeout(() => {
        testCheckFavorite();
    }, 1500);
    
    // Test 3: Get favorites
    setTimeout(() => {
        testGetFavorites();
    }, 3000);
    
    // Test 4: Toggle favorite (remove)
    setTimeout(() => {
        testToggleFavorite();
    }, 4500);
    
    // Test 5: Add favorite profile
    setTimeout(() => {
        testAddFavoriteProfile();
    }, 6000);
}

function testAddFavorite() {
    console.log('📝 Test 1: Add favorite post');
    
    socket.once('favorite:added', (data) => {
        console.log('✅ Favorite added');
        console.log(`   Target Type: ${data.favorite.targetType}`);
        console.log(`   Target ID: ${data.favorite.targetId}`);
        testsCompleted++;
    });
    
    socket.once('favorite:count:updated', (data) => {
        console.log('✅ Favorite count updated');
        console.log(`   Count: ${data.count}`);
    });
    
    socket.emit('favorite:add', {
        targetType: 'Post',
        targetId: '1eb3a0b2-f1ff-417d-bf65-a6dda5329427'
    });
}

function testCheckFavorite() {
    console.log('\n📝 Test 2: Check if favorited');
    
    socket.once('favorite:status', (data) => {
        console.log('✅ Favorite status checked');
        console.log(`   Is Favorited: ${data.isFavorited}`);
        testsCompleted++;
    });
    
    socket.emit('favorite:check', {
        targetType: 'Post',
        targetId: '1eb3a0b2-f1ff-417d-bf65-a6dda5329427'
    });
}

function testGetFavorites() {
    console.log('\n📝 Test 3: Get all favorites');
    
    socket.once('favorites:list', (data) => {
        console.log('✅ Favorites retrieved');
        console.log(`   Total: ${data.pagination.total}`);
        console.log(`   Favorites: ${data.favorites.length}`);
        testsCompleted++;
    });
    
    socket.emit('favorites:get', {
        page: 1,
        limit: 20
    });
}

function testToggleFavorite() {
    console.log('\n📝 Test 4: Toggle favorite (remove)');
    
    socket.once('favorite:toggled', (data) => {
        console.log('✅ Favorite toggled');
        console.log(`   Action: ${data.action}`);
        console.log(`   Is Favorited: ${data.isFavorited}`);
        testsCompleted++;
    });
    
    socket.emit('favorite:toggle', {
        targetType: 'Post',
        targetId: '1eb3a0b2-f1ff-417d-bf65-a6dda5329427'
    });
}

function testAddFavoriteProfile() {
    console.log('\n📝 Test 5: Add favorite profile');
    
    socket.once('favorite:added', (data) => {
        console.log('✅ Profile favorite added');
        console.log(`   Target Type: ${data.favorite.targetType}`);
        console.log(`   Target ID: ${data.favorite.targetId}`);
        testsCompleted++;
        checkCompletion();
    });
    
    socket.emit('favorite:add', {
        targetType: 'Profile',
        targetId: 'ba98ae1c-86c9-4f9e-b9d6-452167334489'
    });
}

function checkCompletion() {
    if (testsCompleted === totalTests) {
        console.log('\n' + '='.repeat(60));
        console.log('📊 TEST RESULTS');
        console.log('='.repeat(60));
        console.log(`✅ All ${totalTests} favorite tests passed!`);
        console.log('Success Rate: 100%');
        console.log('='.repeat(60));
        
        socket.disconnect();
        process.exit(0);
    }
}

// Error handlers
socket.on('error', (error) => {
    console.error('❌ Error:', error.message || error);
});

socket.on('connect_error', (error) => {
    console.error('❌ Connection error:', error.message);
    process.exit(1);
});

// Timeout
setTimeout(() => {
    console.error('\n❌ Test timeout');
    console.log(`Completed: ${testsCompleted}/${totalTests} tests`);
    process.exit(1);
}, 15000);
