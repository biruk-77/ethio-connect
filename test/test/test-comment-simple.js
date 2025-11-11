// Simple comment test
const io = require('socket.io-client');

const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjIzMjc4NzQsImV4cCI6MTc2MjMyODc3NH0.RQtWW83Wi9hW7I8FfFUnASR_jDOfiF-ooi3gXO_tStY';

console.log('Connecting to server...');

const socket = io('http://localhost:5000', {
    auth: { token },
    transports: ['websocket'],
    reconnection: false
});

socket.on('connect', () => {
    console.log('✅ Connected:', socket.id);
});

socket.on('auth:success', (data) => {
    console.log('✅ Authenticated:', data.user.username);
    
    // Create comment AFTER authentication
    console.log('\nCreating comment...');
    socket.emit('comment:create', {
        targetType: 'Post',
        targetId: '1eb3a0b2-f1ff-417d-bf65-a6dda5329427',
        content: 'Test comment from simple test',
        parentId: null
    });
});

socket.on('comment:created', (data) => {
    console.log('✅ Comment created:', data.comment._id);
    console.log('Content:', data.comment.content);
    socket.disconnect();
    process.exit(0);
});

socket.on('connect_error', (error) => {
    console.error('❌ Connection error:', error.message);
    process.exit(1);
});

socket.on('error', (error) => {
    console.error('❌ Socket error:', error.message || error);
    console.error('Full error:', JSON.stringify(error, null, 2));
    process.exit(1);
});

setTimeout(() => {
    console.error('❌ Timeout');
    process.exit(1);
}, 10000);
