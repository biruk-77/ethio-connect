// routes/message.routes.js
const express = require('express');
const router = express.Router();
const Joi = require('joi');
const { messageController } = require('../controllers');
const { authenticateUser, messageLimiter } = require('../middleware');
const { validateBody, validateParams, validateQuery } = require('../middleware/joi.middleware');
const {
    sendMessageSchema,
    paginationSchema
} = require('../validators/message.validator');

/**
 * Message Routes
 * Base path: /api/v1/messages
 */

// Send message
router.post(
    '/send',
    authenticateUser,
    messageLimiter,
    validateBody(sendMessageSchema),
    messageController.sendMessage
);

// Get conversation with specific user
router.get(
    '/conversation/:userId',
    authenticateUser,
    validateParams(Joi.object({ userId: Joi.string().required() })),
    validateQuery(paginationSchema),
    messageController.getConversation
);

// Get all conversations
router.get(
    '/conversations',
    authenticateUser,
    validateQuery(paginationSchema),
    messageController.getConversations
);

// Mark messages as read
router.put(
    '/read/:userId',
    authenticateUser,
    validateParams(Joi.object({ userId: Joi.string().required() })),
    messageController.markAsRead
);

// Delete message
router.delete(
    '/:id',
    authenticateUser,
    validateParams(Joi.object({ id: Joi.string().required() })),
    messageController.deleteMessage
);

// Get unread count
router.get(
    '/unread-count',
    authenticateUser,
    messageController.getUnreadCount
);

module.exports = router;
