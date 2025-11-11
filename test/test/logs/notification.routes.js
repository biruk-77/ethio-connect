// routes/notification.routes.js
const express = require('express');
const router = express.Router();
const Joi = require('joi');
const notificationController = require('../controllers/notification.controller');
const { authenticateUser } = require('../middleware');
const { validateBody, validateParams, validateQuery } = require('../middleware/joi.middleware');

/**
 * Notification Routes
 * Base path: /api/v1/notifications
 */

// Get user notifications
router.get(
    '/',
    authenticateUser,
    validateQuery(Joi.object({
        limit: Joi.number().integer().min(1).max(100).optional(),
        skip: Joi.number().integer().min(0).optional(),
        type: Joi.string().valid('message', 'connection_request', 'connection_accepted', 'connection_rejected', 'mention', 'system').optional(),
        read: Joi.string().valid('true', 'false').optional()
    })),
    notificationController.getNotifications
);

// Get unread count
router.get(
    '/unread-count',
    authenticateUser,
    notificationController.getUnreadCount
);

// Mark notification as read
router.put(
    '/:id/read',
    authenticateUser,
    validateParams(Joi.object({ id: Joi.string().required() })),
    notificationController.markAsRead
);

// Mark all as read
router.put(
    '/read-all',
    authenticateUser,
    notificationController.markAllAsRead
);

// Delete notification
router.delete(
    '/:id',
    authenticateUser,
    validateParams(Joi.object({ id: Joi.string().required() })),
    notificationController.deleteNotification
);

// Test notification (development only)
router.post(
    '/test',
    authenticateUser,
    validateBody(Joi.object({
        title: Joi.string().optional(),
        body: Joi.string().optional(),
        type: Joi.string().valid('message', 'connection_request', 'connection_accepted', 'system').optional()
    })),
    notificationController.testNotification
);

// Send mass notification to all users (admin only)
router.post(
    '/mass',
    authenticateUser,
    validateBody(Joi.object({
        title: Joi.string().required(),
        body: Joi.string().required(),
        type: Joi.string().valid('message', 'connection_request', 'connection_accepted', 'system').optional(),
        data: Joi.object().optional(),
        priority: Joi.string().valid('low', 'normal', 'high').optional(),
        excludeUserIds: Joi.array().items(Joi.string()).optional(),
        activeOnly: Joi.boolean().optional()
    })),
    notificationController.sendMassNotification
);

// Send targeted notification based on criteria (admin only)
router.post(
    '/targeted',
    authenticateUser,
    validateBody(Joi.object({
        criteria: Joi.object({
            userIds: Joi.array().items(Joi.string()).optional(),
            status: Joi.string().valid('online', 'offline', 'away', 'busy').optional(),
            minConnections: Joi.number().integer().min(0).optional(),
            createdAfter: Joi.date().optional(),
            createdBefore: Joi.date().optional()
        }).required(),
        title: Joi.string().required(),
        body: Joi.string().required(),
        type: Joi.string().valid('message', 'connection_request', 'connection_accepted', 'system').optional(),
        data: Joi.object().optional(),
        priority: Joi.string().valid('low', 'normal', 'high').optional()
    })),
    notificationController.sendTargetedNotification
);

// Send segmented notification (admin only)
router.post(
    '/segment/:segment',
    authenticateUser,
    validateParams(Joi.object({
        segment: Joi.string().valid('active_users', 'inactive_users', 'new_users', 'online_users').required()
    })),
    validateBody(Joi.object({
        title: Joi.string().required(),
        body: Joi.string().required(),
        type: Joi.string().valid('message', 'connection_request', 'connection_accepted', 'system').optional(),
        data: Joi.object().optional(),
        priority: Joi.string().valid('low', 'normal', 'high').optional()
    })),
    notificationController.sendSegmentedNotification
);

// Send mass push notification (FCM only, admin only)
router.post(
    '/mass-push',
    authenticateUser,
    validateBody(Joi.object({
        title: Joi.string().required(),
        body: Joi.string().required(),
        data: Joi.object().optional(),
        priority: Joi.string().valid('low', 'normal', 'high').optional(),
        excludeUserIds: Joi.array().items(Joi.string()).optional(),
        activeOnly: Joi.boolean().optional()
    })),
    notificationController.sendMassPush
);

// Trigger notification from external service (User Service)
// No authentication required - internal service call
router.post(
    '/trigger',
    validateBody(Joi.object({
        type: Joi.string().valid('connection_request', 'connection_accepted').required(),
        receiverId: Joi.string().when('type', { is: 'connection_request', then: Joi.required() }),
        requesterId: Joi.string().when('type', { is: 'connection_accepted', then: Joi.required() }),
        connection: Joi.object({
            id: Joi.string().required(),
            status: Joi.string().required()
        }).required(),
        requester: Joi.object({
            id: Joi.string().required(),
            username: Joi.string().required(),
            displayName: Joi.string().optional(),
            photoURL: Joi.string().optional()
        }).when('type', { is: 'connection_request', then: Joi.required() }),
        accepter: Joi.object({
            id: Joi.string().required(),
            username: Joi.string().required(),
            displayName: Joi.string().optional(),
            photoURL: Joi.string().optional()
        }).when('type', { is: 'connection_accepted', then: Joi.required() })
    })),
    notificationController.triggerNotification
);

module.exports = router;
