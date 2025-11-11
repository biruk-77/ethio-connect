/**
 * Test Configuration Template
 * Copy this file to test-config.js and fill in your values
 */

module.exports = {
    serverUrl: 'http://localhost:5000',
    
    // User 1 (Buyer)
    buyer: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // ← Paste buyer JWT token
        // userId will be auto-filled after authentication
    },
    
    // User 2 (Seller)
    seller: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // ← Paste seller JWT token
        // userId will be auto-filled after authentication
    },
    
    // Test Post
    post: {
        id: '507f1f77bcf86cd799439011',  // ← Paste MongoDB ObjectId of post
        type: 'marketplace'               // marketplace, service, job, etc.
    }
};

/**
 * How to get tokens:
 * 
 * 1. Login via User Service:
 *    POST http://localhost:3000/api/auth/login
 *    Body: { "email": "buyer@example.com", "password": "password123" }
 *    Response: { "token": "eyJhbGc..." }
 * 
 * 2. Copy the token from response
 * 
 * 3. Repeat for seller user
 * 
 * 4. Get post ID from Post Service or MongoDB
 */

/**
 * Quick test without running full suite:
 * 
 * const io = require('socket.io-client');
 * const config = require('./test-config');
 * 
 * const socket = io(config.serverUrl, {
 *     auth: { token: config.buyer.token }
 * });
 * 
 * socket.on('auth:success', (data) => {
 *     console.log('Authenticated:', data.user);
 *     
 *     // Send message
 *     socket.emit('message:send', {
 *         receiverId: 'seller-user-id',
 *         content: 'Test message',
 *         postId: config.post.id,
 *         postType: config.post.type,
 *         isFirstMessage: true
 *     });
 * });
 * 
 * socket.on('message:sent', (data) => {
 *     console.log('Message sent:', data.message);
 * });
 */
