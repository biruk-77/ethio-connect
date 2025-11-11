// routes/index.js
const express = require('express');
const router = express.Router();
const userRoutes = require('./user.routes');
const messageRoutes = require('./message.routes');
const uploadRoutes = require('./upload.routes');
const notificationRoutes = require('./notification.routes');
const commentRoutes = require('./comment.routes');

/**
 * API Routes
 * Version: v1
 */

// Health check
router.get('/health', (req, res) => {
    res.status(200).json({
        status: 'OK',
        message: 'Communication Service is running',
        timestamp: new Date().toISOString()
    });
});

// Mount routes
router.use('/users', userRoutes);
router.use('/messages', messageRoutes);
router.use('/uploads', uploadRoutes);
router.use('/notifications', notificationRoutes);
router.use('/comments', commentRoutes);

module.exports = router;
