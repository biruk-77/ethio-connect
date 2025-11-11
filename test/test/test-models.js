// Test all MongoDB models
const mongoose = require('mongoose');
require('dotenv').config();

const {
    User,
    Message,
    Notification,
    Comment,
    UserStatus,
    Like,
    Favorite
} = require('../models');

async function testModels() {
    try {
        console.log('🧪 Testing MongoDB Models\n');
        
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB\n');
        
        // Test each model
        console.log('📋 Available Models:');
        console.log('  1. ✅ User');
        console.log('  2. ✅ Message');
        console.log('  3. ✅ Notification');
        console.log('  4. ✅ Comment');
        console.log('  5. ✅ UserStatus');
        console.log('  6. ✅ Like');
        console.log('  7. ✅ Favorite');
        
        console.log('\n📊 Model Statistics:');
        
        const userCount = await User.countDocuments();
        console.log(`  Users: ${userCount}`);
        
        const messageCount = await Message.countDocuments();
        console.log(`  Messages: ${messageCount}`);
        
        const notificationCount = await Notification.countDocuments();
        console.log(`  Notifications: ${notificationCount}`);
        
        const commentCount = await Comment.countDocuments();
        console.log(`  Comments: ${commentCount}`);
        
        const userStatusCount = await UserStatus.countDocuments();
        console.log(`  User Statuses: ${userStatusCount}`);
        
        const likeCount = await Like.countDocuments();
        console.log(`  Likes: ${likeCount}`);
        
        const favoriteCount = await Favorite.countDocuments();
        console.log(`  Favorites: ${favoriteCount}`);
        
        console.log('\n✅ All models loaded successfully!');
        
        await mongoose.disconnect();
        process.exit(0);
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
}

testModels();
