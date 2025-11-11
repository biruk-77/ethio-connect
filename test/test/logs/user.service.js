// src/services/user.service.js
const { User } = require('../models');
const { AppError } = require('../middleware/error.middleware');
const logger = require('../config/logger.config');

/**
 * User Service - Business logic for user operations
 */
class UserService {
    /**
     * Get user profile
     */
    async getUserProfile(userId) {
        try {
            const user = await User.findById(userId);
            
            if (!user) {
                throw new AppError('User not found', 404);
            }

            return user;
        } catch (error) {
            logger.error('Get user profile error:', error);
            throw error;
        }
    }

    /**
     * Update user profile
     */
    async updateUserProfile(userId, updates) {
        try {
            const allowedUpdates = ['username', 'displayName', 'photoURL', 'status'];
            const filteredUpdates = {};

            // Filter allowed updates
            Object.keys(updates).forEach(key => {
                if (allowedUpdates.includes(key)) {
                    filteredUpdates[key] = updates[key];
                }
            });

            const user = await User.findByIdAndUpdate(
                userId,
                { $set: filteredUpdates },
                { new: true, runValidators: true }
            );

            if (!user) {
                throw new AppError('User not found', 404);
            }

            logger.info(`User profile updated: ${userId}`);
            return user;
        } catch (error) {
            logger.error('Update user profile error:', error);
            throw error;
        }
    }

    /**
     * Update user status
     */
    async updateUserStatus(userId, status) {
        try {
            const user = await User.findById(userId);
            
            if (!user) {
                throw new AppError('User not found', 404);
            }

            await user.updateStatus(status);
            return user;
        } catch (error) {
            logger.error('Update user status error:', error);
            throw error;
        }
    }

    /**
     * Search users
     */
    async searchUsers(query, limit = 10) {
        try {
            const users = await User.searchUsers(query, limit);
            return users;
        } catch (error) {
            logger.error('Search users error:', error);
            throw error;
        }
    }

    /**
     * Add FCM token for push notifications
     */
    async addFcmToken(userId, token, device) {
        try {
            const user = await User.findById(userId);
            
            if (!user) {
                throw new AppError('User not found', 404);
            }

            await user.addFcmToken(token, device);
            logger.info(`FCM token added for user: ${userId}`);
            return user;
        } catch (error) {
            logger.error('Add FCM token error:', error);
            throw error;
        }
    }

    /**
     * Remove FCM token
     */
    async removeFcmToken(userId, token) {
        try {
            const user = await User.findById(userId);
            
            if (!user) {
                throw new AppError('User not found', 404);
            }

            await user.removeFcmToken(token);
            logger.info(`FCM token removed for user: ${userId}`);
            return user;
        } catch (error) {
            logger.error('Remove FCM token error:', error);
            throw error;
        }
    }

    /**
     * Deactivate user account
     */
    async deactivateAccount(userId) {
        try {
            const user = await User.findByIdAndUpdate(
                userId,
                { $set: { isActive: false } },
                { new: true }
            );

            if (!user) {
                throw new AppError('User not found', 404);
            }

            logger.info(`User account deactivated: ${userId}`);
            return user;
        } catch (error) {
            logger.error('Deactivate account error:', error);
            throw error;
        }
    }
}

module.exports = new UserService();
