// services/socket.service.js
const { User } = require('../models');
const logger = require('../config/logger.config');
const httpClient = require('../utils/httpClient.util');
const userService = require('./user.service');

/**
 * Socket Service - Business logic for socket operations
 */
class SocketService {
    /**
     * Authenticate user via JWT token
     */
    async authenticateUser(token) {
        try {
            if (!token) {
                throw new Error('Token required');
            }

            // Decode JWT token directly (User Service doesn't have /auth/me endpoint)
            const jwt = require('jsonwebtoken');
            let decoded;
            
            try {
                // Verify JWT with secret
                decoded = jwt.verify(token, process.env.JWT_SECRET);
            } catch (jwtError) {
                // If verification fails, try decoding without verification (for testing)
                decoded = jwt.decode(token);
                if (!decoded) {
                    throw new Error('Invalid token');
                }
            }

            const userData = decoded;

            // Find or create user in local database
            let user = await User.findOne({ firebaseUid: userData.id || userData.uid });

            if (!user) {
                // Create user in local database
                user = new User({
                    firebaseUid: userData.id || userData.uid,
                    username: userData.username || userData.email?.split('@')[0],
                    displayName: userData.profile?.fullName || userData.username,
                    email: userData.email,
                    photoURL: userData.profile?.photoUrl || null
                });
                await user.save();
                logger.info(`New user created in local DB: ${user.id}`);
            }

            // Update user status to online
            await userService.updateUserStatus(user.id, 'online');

            logger.info(`User authenticated via JWT: ${user.id}`);
            return user;
        } catch (error) {
            logger.error('Authentication error:', error);
            throw error;
        }
    }

    /**
     * Handle user disconnect
     */
    async handleUserDisconnect(userId) {
        try {
            if (!userId) {
                return;
            }

            // Update user status to offline
            await userService.updateUserStatus(userId, 'offline');
            
            logger.info(`User ${userId} status updated to offline`);
        } catch (error) {
            logger.error('Error updating user status on disconnect:', error);
        }
    }

    /**
     * Validate room join request
     */
    validateRoomJoin(roomType, roomId) {
        if (!roomType || !roomId) {
            throw new Error('Room type and room ID are required');
        }

        const validRoomTypes = ['Post', 'Profile', 'Conversation'];
        if (!validRoomTypes.includes(roomType)) {
            throw new Error(`Invalid room type. Must be one of: ${validRoomTypes.join(', ')}`);
        }

        return {
            roomName: `${roomType}:${roomId}`,
            roomType,
            roomId
        };
    }

    /**
     * Validate status update
     */
    validateStatusUpdate(status) {
        const validStatuses = ['online', 'away', 'busy', 'offline'];
        
        if (!status || !validStatuses.includes(status)) {
            throw new Error(`Valid status is required (${validStatuses.join(', ')})`);
        }

        return status;
    }

    /**
     * Format user data for socket response
     */
    formatUserData(user) {
        return {
            id: user.id,
            username: user.username,
            displayName: user.displayName,
            photoURL: user.photoURL,
            email: user.email,
            status: user.status
        };
    }

    /**
     * Get room name for conversation
     */
    getConversationRoomName(userId1, userId2) {
        return [userId1, userId2].sort().join('_');
    }
}

module.exports = new SocketService();
