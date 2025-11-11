// services/userStatus.service.js
const UserStatus = require('../models/UserStatus.model');
const logger = require('../config/logger.config');

/**
 * UserStatus Service - Manages user online/offline status
 */
class UserStatusService {
    /**
     * Update user status
     */
    async updateUserStatus(userId, status, socketId = null) {
        try {
            const userStatus = await UserStatus.findOneAndUpdate(
                { userId },
                {
                    status,
                    socketId,
                    lastSeen: new Date()
                },
                { upsert: true, new: true }
            );

            logger.info(`User ${userId} status updated to ${status}`);
            return userStatus;
        } catch (error) {
            logger.error('Error updating user status:', error);
            throw error;
        }
    }

    /**
     * Set user online
     */
    async setUserOnline(userId, socketId) {
        return await this.updateUserStatus(userId, 'online', socketId);
    }

    /**
     * Set user offline
     */
    async setUserOffline(userId) {
        return await this.updateUserStatus(userId, 'offline', null);
    }

    /**
     * Set typing status
     */
    async setTypingStatus(userId, typingToUserId) {
        try {
            const userStatus = await UserStatus.findOneAndUpdate(
                { userId },
                { typingToUserId },
                { new: true }
            );

            logger.info(`User ${userId} typing to ${typingToUserId}`);
            return userStatus;
        } catch (error) {
            logger.error('Error setting typing status:', error);
            throw error;
        }
    }

    /**
     * Clear typing status
     */
    async clearTypingStatus(userId) {
        return await this.setTypingStatus(userId, null);
    }

    /**
     * Get user status
     */
    async getUserStatus(userId) {
        try {
            const userStatus = await UserStatus.findOne({ userId });
            return userStatus || { userId, status: 'offline', lastSeen: null };
        } catch (error) {
            logger.error('Error getting user status:', error);
            throw error;
        }
    }

    /**
     * Get multiple users' statuses
     */
    async getUsersStatuses(userIds) {
        try {
            const statuses = await UserStatus.find({ userId: { $in: userIds } });
            
            // Create a map for quick lookup
            const statusMap = {};
            statuses.forEach(status => {
                statusMap[status.userId] = status;
            });

            // Fill in missing users with offline status
            return userIds.map(userId => 
                statusMap[userId] || { userId, status: 'offline', lastSeen: null }
            );
        } catch (error) {
            logger.error('Error getting users statuses:', error);
            throw error;
        }
    }

    /**
     * Get online users
     */
    async getOnlineUsers() {
        try {
            return await UserStatus.find({ status: 'online' });
        } catch (error) {
            logger.error('Error getting online users:', error);
            throw error;
        }
    }

    /**
     * Clean up stale connections
     */
    async cleanupStaleConnections(maxAgeMinutes = 30) {
        try {
            const cutoffTime = new Date(Date.now() - maxAgeMinutes * 60 * 1000);
            
            const result = await UserStatus.updateMany(
                {
                    status: 'online',
                    lastSeen: { $lt: cutoffTime }
                },
                {
                    status: 'offline',
                    socketId: null
                }
            );

            logger.info(`Cleaned up ${result.modifiedCount} stale connections`);
            return result;
        } catch (error) {
            logger.error('Error cleaning up stale connections:', error);
            throw error;
        }
    }
}

module.exports = new UserStatusService();
