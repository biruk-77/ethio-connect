// src/services/message.service.js
const { Message, User } = require('../models');
const { AppError } = require('../middleware/error.middleware');
const logger = require('../config/logger.config');

/**
 * Message Service - Business logic for message operations
 */
class MessageService {
    /**
     * Send a message
     */
    async sendMessage(senderId, receiverId, content, options = {}) {
        try {
            const {
                messageType = 'text',
                attachments = [],
                postId = null,
                postType = null,
                isFirstMessage = false
            } = options;

            // Validate input
            if (!senderId || !receiverId || !content) {
                throw new AppError('Sender ID, receiver ID, and content are required', 400);
            }

            // Prevent self-messaging
            if (senderId === receiverId) {
                throw new AppError('Cannot send messages to yourself', 400);
            }

            // Check if receiver exists
            const receiver = await User.findById(receiverId);
            if (!receiver) {
                throw new AppError('Receiver not found', 404);
            }

            // Marketplace messaging - no connection check required
            // All messages are post-based, users can message about any listing

            // Create message
            const message = await Message.create({
                senderId,
                receiverId,
                content,
                messageType,
                attachments,
                postId,
                postType,
                isFirstMessage
            });

            // Populate sender and receiver details
            await message.populate([
                { path: 'senderId', select: 'username displayName photoURL' },
                { path: 'receiverId', select: 'username displayName photoURL' }
            ]);

            logger.info(`Message sent from ${senderId} to ${receiverId}${postId ? ` about post ${postId}` : ''}`);
            return message;
        } catch (error) {
            logger.error('Send message error:', error);
            throw error;
        }
    }

    /**
     * Get conversation between two users
     */
    async getConversation(userId, otherUserId, options = {}) {
        try {
            const { postId = null } = options;

            // Prevent self-conversation
            if (userId === otherUserId) {
                throw new AppError('Cannot view conversations with yourself', 400);
            }

            // Check if other user exists
            const otherUser = await User.findById(otherUserId);
            if (!otherUser) {
                throw new AppError('User not found', 404);
            }

            // Get messages (with optional postId filter)
            const messages = await Message.getConversation(userId, otherUserId, { ...options, postId });
            
            // Count total messages
            const countQuery = {
                $or: [
                    { senderId: userId, receiverId: otherUserId },
                    { senderId: otherUserId, receiverId: userId }
                ],
                isDeleted: false
            };

            if (postId) {
                countQuery.postId = postId;
            }

            const totalMessages = await Message.countDocuments(countQuery);
            const limit = parseInt(options.limit) || 50;
            const page = parseInt(options.page) || 1;

            return {
                messages: messages.reverse(), // Show oldest first
                pagination: {
                    total: totalMessages,
                    page,
                    limit,
                    totalPages: Math.ceil(totalMessages / limit)
                }
            };
        } catch (error) {
            logger.error('Get conversation error:', error);
            throw error;
        }
    }

    /**
     * Get all conversations for a user
     */
    async getUserConversations(userId, options = {}) {
        try {
            const conversations = await Message.getUserConversations(userId, options);
            return conversations;
        } catch (error) {
            logger.error('Get user conversations error:', error);
            throw error;
        }
    }

    /**
     * Mark messages as read
     */
    async markMessagesAsRead(userId, otherUserId) {
        try {
            const result = await Message.markConversationAsRead(userId, otherUserId);
            logger.info(`${result.modifiedCount} messages marked as read for user ${userId}`);
            return result.modifiedCount;
        } catch (error) {
            logger.error('Mark messages as read error:', error);
            throw error;
        }
    }

    /**
     * Mark single message as read
     */
    async markMessageAsRead(messageId, userId) {
        try {
            const message = await Message.findById(messageId);
            
            if (!message) {
                throw new AppError('Message not found', 404);
            }

            if (message.receiverId.toString() !== userId) {
                throw new AppError('You can only mark messages you received as read', 403);
            }

            await message.markAsRead();
            return message;
        } catch (error) {
            logger.error('Mark message as read error:', error);
            throw error;
        }
    }

    /**
     * Delete a message
     */
    async deleteMessage(messageId, userId) {
        try {
            const message = await Message.findById(messageId);
            
            if (!message) {
                throw new AppError('Message not found', 404);
            }

            if (message.senderId.toString() !== userId) {
                throw new AppError('You can only delete your own messages', 403);
            }

            await message.softDelete(userId);
            logger.info(`Message ${messageId} deleted by user ${userId}`);
            
            return message;
        } catch (error) {
            logger.error('Delete message error:', error);
            throw error;
        }
    }

    /**
     * Get unread message count
     */
    async getUnreadCount(userId) {
        try {
            const count = await Message.getUnreadCount(userId);
            return count;
        } catch (error) {
            logger.error('Get unread count error:', error);
            throw error;
        }
    }

    /**
     * Get message by ID
     */
    async getMessageById(messageId) {
        try {
            const message = await Message.findById(messageId)
                .populate('senderId', 'username displayName photoURL')
                .populate('receiverId', 'username displayName photoURL');
            
            if (!message) {
                throw new AppError('Message not found', 404);
            }

            return message;
        } catch (error) {
            logger.error('Get message by ID error:', error);
            throw error;
        }
    }

    /**
     * Get all inquiries for a specific post (seller view)
     */
    async getPostInquiries(postId, sellerId) {
        try {
            if (!postId || !sellerId) {
                throw new AppError('Post ID and seller ID are required', 400);
            }

            const inquiries = await Message.getPostConversations(postId, sellerId);
            
            return {
                inquiries,
                total: inquiries.length
            };
        } catch (error) {
            logger.error('Get post inquiries error:', error);
            throw error;
        }
    }

    /**
     * Mark entire conversation as read
     */
    async markConversationAsRead(userId, otherUserId) {
        try {
            const result = await Message.markConversationAsRead(userId, otherUserId);
            logger.info(`${result.modifiedCount} messages marked as read for user ${userId}`);
            return result.modifiedCount;
        } catch (error) {
            logger.error('Mark conversation as read error:', error);
            throw error;
        }
    }

    /**
     * Get conversation room name for socket
     */
    getConversationRoomName(userId1, userId2) {
        return [userId1, userId2].sort().join('_');
    }
}

module.exports = new MessageService();
