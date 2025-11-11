// routes/user.routes.js
const express = require('express');
const router = express.Router();
const Joi = require('joi');
const { userController } = require('../controllers');
const { authenticateUser } = require('../middleware');
const { validateBody, validateQuery } = require('../middleware/joi.middleware');
const { uploadImage } = require('../config/multer.config');
const {
    updateProfileSchema,
    searchUsersSchema,
    updateStatusSchema,
    updateFCMTokenSchema
} = require('../validators/user.validator');

/**
 * User Routes
 * Base path: /api/v1/users
 */

// Get current user profile
router.get(
    '/profile',
    authenticateUser,
    userController.getProfile
);

// Update user profile
router.put(
    '/profile',
    authenticateUser,
    validateBody(updateProfileSchema),
    userController.updateProfile
);

// Upload profile photo
router.post(
    '/profile/photo',
    authenticateUser,
    uploadImage.single('photo'),
    userController.uploadProfilePhoto
);

// Delete profile photo
router.delete(
    '/profile/photo',
    authenticateUser,
    userController.deleteProfilePhoto
);

// Update user status
router.put(
    '/status',
    authenticateUser,
    validateBody(updateStatusSchema),
    userController.updateStatus
);

// Search users
router.get(
    '/search',
    authenticateUser,
    validateQuery(searchUsersSchema),
    userController.searchUsers
);

// Add FCM token
router.post(
    '/fcm-token',
    authenticateUser,
    validateBody(updateFCMTokenSchema),
    userController.addFcmToken
);

// Remove FCM token
router.delete(
    '/fcm-token',
    authenticateUser,
    userController.removeFcmToken
);

// Deactivate account
router.delete(
    '/account',
    authenticateUser,
    userController.deactivateAccount
);

module.exports = router;
