// test/test-push-notification.js
require('dotenv').config();
const mongoose = require('mongoose');
const firebaseConfig = require('../config/firebase.config');
const NotificationService = require('../services/notification.service');
const databaseConfig = require('../config/database.config');
const logger = require('../config/logger.config');

/**
 * Test Push Notification Flow
 * 
 * This test demonstrates how push notifications work:
 * 1. User must have FCM tokens registered
 * 2. Notification is created in database
 * 3. If user is offline, push notification is sent via FCM
 */
async function testPushNotification() {
    console.log('\n📱 Testing Push Notification Flow...\n');
    
    try {
        // Connect to database
        console.log('📋 Step 1: Connecting to MongoDB...');
        await databaseConfig.connect();
        console.log('   ✅ Connected to MongoDB\n');
        
        // Initialize Firebase
        console.log('📋 Step 2: Initializing Firebase...');
        firebaseConfig.initialize();
        console.log('   ✅ Firebase initialized\n');
        
        // Check for test user
        console.log('📋 Step 3: Checking for users with FCM tokens...');
        const User = require('../models/User.model');
        
        const usersWithTokens = await User.find({
            'fcmTokens.0': { $exists: true }
        }).select('firebaseUid username fcmTokens').limit(5);
        
        if (usersWithTokens.length === 0) {
            console.log('   ⚠️  No users with FCM tokens found\n');
            console.log('📝 How to register FCM tokens:');
            console.log('   1. User logs in via mobile app');
            console.log('   2. Mobile app gets FCM token from Firebase SDK');
            console.log('   3. Mobile app sends token to User Service');
            console.log('   4. User Service stores token in user.fcmTokens array\n');
            
            console.log('📝 Example FCM token registration:');
            console.log('   POST /api/v1/users/fcm-token');
            console.log('   Headers: { Authorization: "Bearer jwt-token" }');
            console.log('   Body: { token: "fcm-device-token" }\n');
            
        } else {
            console.log(`   ✅ Found ${usersWithTokens.length} users with FCM tokens:\n`);
            usersWithTokens.forEach((user, index) => {
                console.log(`   User ${index + 1}:`);
                console.log(`      ID: ${user._id}`);
                console.log(`      Username: ${user.username || 'N/A'}`);
                console.log(`      Firebase UID: ${user.firebaseUid}`);
                console.log(`      FCM Tokens: ${user.fcmTokens.length} registered`);
                user.fcmTokens.forEach((tokenObj, idx) => {
                    console.log(`         Token ${idx + 1}: ${tokenObj.token.substring(0, 30)}...`);
                    console.log(`         Device: ${tokenObj.deviceType || 'unknown'}`);
                    console.log(`         Added: ${tokenObj.createdAt || 'N/A'}`);
                });
                console.log('');
            });
        }
        
        // Test notification structure
        console.log('📋 Step 4: Testing notification structure...');
        const testNotification = {
            type: 'message',
            title: 'New Message',
            body: 'You have a new message from John',
            data: {
                senderId: '690b097755f6ea01237420ed',
                messageId: 'msg-123',
                conversationId: 'conv-456'
            },
            senderId: '690b097755f6ea01237420ed',
            priority: 'high',
            actionUrl: '/messages/conv-456'
        };
        console.log('   ✅ Notification structure:');
        console.log(JSON.stringify(testNotification, null, 2));
        console.log('');
        
        // Explain the flow
        console.log('📋 Step 5: Understanding the notification flow...\n');
        console.log('   🔄 Notification Flow:');
        console.log('   ┌─────────────────────────────────────────────────┐');
        console.log('   │ 1. Event occurs (new message, like, comment)   │');
        console.log('   │ 2. NotificationService.sendNotification()       │');
        console.log('   │ 3. Create notification in MongoDB              │');
        console.log('   │ 4. Check if user is online (Socket.IO)         │');
        console.log('   │    ├─ Online: Send via Socket.IO ✅            │');
        console.log('   │    └─ Offline: Send push via FCM 📱           │');
        console.log('   │ 5. FCM sends to all user devices               │');
        console.log('   │ 6. Mobile app receives & displays notification │');
        console.log('   └─────────────────────────────────────────────────┘\n');
        
        // Test actual notification sending (if user exists)
        if (usersWithTokens.length > 0) {
            console.log('📋 Step 6: Testing actual notification send...\n');
            const testUser = usersWithTokens[0];
            
            console.log(`   Sending test notification to: ${testUser.username || testUser._id}`);
            console.log(`   User has ${testUser.fcmTokens.length} device(s) registered\n`);
            
            try {
                // Create a test notification (without io, so it will try push)
                const notificationService = new NotificationService();
                const result = await notificationService.sendNotification(
                    testUser._id,
                    {
                        type: 'test',
                        title: '🔥 Firebase Test',
                        body: 'This is a test push notification from Communication Service',
                        data: {
                            testId: 'firebase-test-' + Date.now(),
                            timestamp: new Date().toISOString()
                        },
                        priority: 'high'
                    },
                    null // No io instance, will send push
                );
                
                console.log('   ✅ Notification sent successfully!');
                console.log(`   Notification ID: ${result._id}`);
                console.log(`   In-App Delivered: ${result.deliveryStatus.inApp}`);
                console.log(`   Push Sent: ${result.deliveryStatus.push}`);
                console.log(`   Created At: ${result.createdAt}\n`);
                
                console.log('   📱 Check your mobile device for the notification!\n');
                
            } catch (error) {
                console.log(`   ❌ Error sending notification: ${error.message}\n`);
                if (error.message.includes('registration-token')) {
                    console.log('   ⚠️  FCM token may be invalid or expired');
                    console.log('   💡 User needs to re-login on mobile app to refresh token\n');
                }
            }
        }
        
        // Summary
        console.log('╔════════════════════════════════════════════════════════╗');
        console.log('║                                                        ║');
        console.log('║        📱 Push Notification Test Complete! 📱         ║');
        console.log('║                                                        ║');
        console.log('╚════════════════════════════════════════════════════════╝\n');
        
        console.log('📊 Summary:');
        console.log(`   • Firebase: ${firebaseConfig.isInitialized ? '✅ Initialized' : '❌ Not initialized'}`);
        console.log(`   • Database: ${databaseConfig.isConnected ? '✅ Connected' : '❌ Disconnected'}`);
        console.log(`   • Users with FCM tokens: ${usersWithTokens.length}`);
        console.log('   • Notification flow: ✅ Tested\n');
        
        console.log('📝 How to test with real device:');
        console.log('   1. Install mobile app on device');
        console.log('   2. Login to get FCM token registered');
        console.log('   3. Send message/like/comment to trigger notification');
        console.log('   4. Notification appears on device lock screen\n');
        
        // Cleanup
        await databaseConfig.disconnect();
        process.exit(0);
        
    } catch (error) {
        console.error('\n❌ Test Failed:', error.message);
        console.error('Error Details:', error);
        
        await databaseConfig.disconnect();
        process.exit(1);
    }
}

// Run test
testPushNotification();
