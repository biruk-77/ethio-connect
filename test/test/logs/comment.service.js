// services/comment.service.js
const httpClient = require('../utils/httpClient.util');
const logger = require('../config/logger.config');
const { Comment } = require('../models');

/**
 * Comment Service - Handles thread-based commenting on posts
 * Comments are stored locally in Communication Service MongoDB
 * Only verifies user/post existence via external services
 */
class CommentService {
    /**
     * Create a new comment on a post
     */
    async createComment(commentData, userId, token = null) {
        try {
            logger.info(`[Comment Service] Creating comment for user ${userId}`);
            const { targetType, targetId, content, parentId } = commentData;

            // Validate target type
            if (!['Post', 'Profile'].includes(targetType)) {
                throw new Error('Invalid target type. Must be Post or Profile');
            }
            logger.info(`[Comment Service] Target: ${targetType}:${targetId}`);

            // Verify user exists (skip if we have JWT token with user data)
            // JWT tokens from User Service already contain verified user data
            if (!token) {
                const userVerification = await httpClient.verifyUser(userId, token);
                if (!userVerification.exists) {
                    throw new Error('User not found');
                }
            }
            // If token exists, user is already verified via JWT authentication

            // Verify target exists based on type
            if (targetType === 'Post') {
                const postVerification = await httpClient.verifyPost(targetId, token);
                if (!postVerification.exists) {
                    throw new Error('Post not found');
                }
            } else if (targetType === 'Profile') {
                const profileVerification = await httpClient.verifyUser(targetId, token);
                if (!profileVerification.exists) {
                    throw new Error('Profile not found');
                }
            }

            // If it's a reply, verify parent comment exists
            if (parentId) {
                const parentComment = await Comment.findById(parentId);
                if (!parentComment) {
                    throw new Error('Parent comment not found');
                }
                
                // Ensure reply is on the same target
                if (parentComment.targetType !== targetType || 
                    parentComment.targetId !== targetId) {
                    throw new Error('Parent comment is not on this target');
                }
            }

            // Create comment in local database
            const comment = new Comment({
                userId,
                targetType,
                targetId,
                content,
                parentId: parentId || null,
                isApproved: true
            });

            await comment.save();

            // Increment parent's reply count if this is a reply
            if (parentId) {
                await Comment.incrementRepliesCount(parentId);
            }

            logger.info(`Comment created: ${comment._id} on ${targetType} ${targetId} by user ${userId}`);

            return {
                success: true,
                data: comment.toObject()
            };
        } catch (error) {
            logger.error('Error creating comment:', error);
            throw error;
        }
    }

    /**
     * Get comments for a target (post or profile)
     */
    async getTargetComments(targetType, targetId, options = {}, token = null) {
        try {
            // Validate target type
            if (!['Post', 'Profile'].includes(targetType)) {
                throw new Error('Invalid target type. Must be Post or Profile');
            }

            // Verify target exists
            if (targetType === 'Post') {
                const postVerification = await httpClient.verifyPost(targetId, token);
                if (!postVerification.exists) {
                    throw new Error('Post not found');
                }
            } else if (targetType === 'Profile') {
                const profileVerification = await httpClient.verifyUser(targetId, token);
                if (!profileVerification.exists) {
                    throw new Error('Profile not found');
                }
            }

            const result = await Comment.getTargetComments(targetType, targetId, options);

            return {
                success: true,
                data: result
            };
        } catch (error) {
            logger.error('Error fetching target comments:', error);
            throw error;
        }
    }

    /**
     * Get replies to a comment
     */
    async getCommentReplies(commentId, options = {}, token = null) {
        try {
            const comment = await Comment.findById(commentId);
            if (!comment) {
                throw new Error('Comment not found');
            }

            const result = await Comment.getCommentReplies(commentId, options);

            return {
                success: true,
                data: result
            };
        } catch (error) {
            logger.error('Error fetching comment replies:', error);
            throw error;
        }
    }

    /**
     * Get a single comment by ID
     */
    async getCommentById(commentId, token = null) {
        try {
            const comment = await Comment.findById(commentId).lean();

            if (!comment) {
                throw new Error('Comment not found');
            }

            return {
                success: true,
                data: comment
            };
        } catch (error) {
            logger.error('Error fetching comment:', error);
            throw error;
        }
    }

    /**
     * Update a comment
     */
    async updateComment(commentId, userId, content, token = null) {
        try {
            const comment = await Comment.findById(commentId);

            if (!comment) {
                throw new Error('Comment not found');
            }

            // Check ownership
            if (comment.userId !== userId) {
                throw new Error('Unauthorized to update this comment');
            }

            comment.content = content;
            comment.isEdited = true;
            comment.editedAt = new Date();
            await comment.save();

            logger.info(`Comment updated: ${commentId} by user ${userId}`);

            return {
                success: true,
                data: comment.toObject()
            };
        } catch (error) {
            logger.error('Error updating comment:', error);
            throw error;
        }
    }

    /**
     * Delete a comment
     */
    async deleteComment(commentId, userId, token = null) {
        try {
            const comment = await Comment.findById(commentId);

            if (!comment) {
                throw new Error('Comment not found');
            }

            // Check ownership
            if (comment.userId !== userId) {
                throw new Error('Unauthorized to delete this comment');
            }

            // Delete comment and all its replies
            await Comment.deleteCommentAndReplies(commentId);

            logger.info(`Comment deleted: ${commentId} by user ${userId}`);

            return {
                success: true,
                message: 'Comment deleted successfully',
                data: comment.toObject()
            };
        } catch (error) {
            logger.error('Error deleting comment:', error);
            throw error;
        }
    }

    /**
     * Get user's comments
     */
    async getUserComments(userId, options = {}, token = null) {
        try {
            const result = await Comment.getUserComments(userId, options);

            return {
                success: true,
                data: result
            };
        } catch (error) {
            logger.error('Error fetching user comments:', error);
            throw error;
        }
    }

    /**
     * Get comment statistics for a target
     */
    async getCommentStats(targetType, targetId, token = null) {
        try {
            // Validate target type
            if (!['Post', 'Profile'].includes(targetType)) {
                throw new Error('Invalid target type. Must be Post or Profile');
            }

            const stats = await Comment.getCommentStats(targetType, targetId);

            return {
                success: true,
                data: stats
            };
        } catch (error) {
            logger.error('Error fetching comment stats:', error);
            throw error;
        }
    }

    /**
     * Notify target owner about new comment (internal method)
     */
    async notifyTargetOwner(targetType, targetId, comment, token) {
        try {
            if (targetType === 'Post') {
                const commentData = {
                    commentId: comment.id,
                    userId: comment.userId,
                    content: comment.content.substring(0, 100),
                    createdAt: comment.createdAt
                };

                await httpClient.notifyPostOwner(targetId, commentData, token);
            }
            // Add profile notification logic if needed
        } catch (error) {
            logger.error('Error notifying target owner:', error);
            // Don't throw, this is a non-critical operation
        }
    }

    /**
     * Get comment thread (comment with all its replies)
     */
    async getCommentThread(commentId, options = {}, token = null) {
        try {
            const comment = await Comment.findById(commentId).lean();

            if (!comment) {
                throw new Error('Comment not found');
            }

            const replies = await Comment.getCommentReplies(commentId, options);

            return {
                success: true,
                data: {
                    comment,
                    replies: replies.replies || []
                }
            };
        } catch (error) {
            logger.error('Error fetching comment thread:', error);
            throw error;
        }
    }

    /**
     * Moderate comment (approve/reject)
     */
    async moderateComment(commentId, isApproved, token = null) {
        try {
            const comment = await Comment.findByIdAndUpdate(
                commentId,
                { isApproved },
                { new: true }
            );

            if (!comment) {
                throw new Error('Comment not found');
            }

            logger.info(`Comment ${commentId} moderation status: ${isApproved}`);

            return {
                success: true,
                data: comment.toObject()
            };
        } catch (error) {
            logger.error('Error moderating comment:', error);
            throw error;
        }
    }
}

module.exports = new CommentService();
