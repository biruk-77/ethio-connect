// services/like.service.js
const Like = require('../models/Like.model');
const logger = require('../config/logger.config');

/**
 * Like Service - Manages matchmaking likes/skips
 */
class LikeService {
    /**
     * Create or update a like
     */
    async createLike(likerId, likedId, status = 'like') {
        try {
            if (likerId === likedId) {
                throw new Error('Cannot like yourself');
            }

            const like = await Like.findOneAndUpdate(
                { likerId, likedId },
                { status },
                { upsert: true, new: true }
            );

            logger.info(`User ${likerId} ${status}d user ${likedId}`);

            // Check for mutual like
            const isMutual = await Like.checkMutualLike(likerId, likedId);

            return {
                like,
                isMutual
            };
        } catch (error) {
            logger.error('Error creating like:', error);
            throw error;
        }
    }

    /**
     * Unlike a user
     */
    async unlike(likerId, likedId) {
        try {
            const result = await Like.deleteOne({ likerId, likedId });
            logger.info(`User ${likerId} unliked user ${likedId}`);
            return result;
        } catch (error) {
            logger.error('Error unliking:', error);
            throw error;
        }
    }

    /**
     * Get user's likes
     */
    async getUserLikes(userId, options = {}) {
        try {
            const {
                page = 1,
                limit = 20,
                status = 'like'
            } = options;

            const skip = (page - 1) * limit;

            const likes = await Like.find({ likerId: userId, status })
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(limit)
                .lean();

            const total = await Like.countDocuments({ likerId: userId, status });

            return {
                likes,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit)
                }
            };
        } catch (error) {
            logger.error('Error getting user likes:', error);
            throw error;
        }
    }

    /**
     * Get users who liked a user
     */
    async getUserLikers(userId, options = {}) {
        try {
            const {
                page = 1,
                limit = 20
            } = options;

            const skip = (page - 1) * limit;

            const likes = await Like.find({ likedId: userId, status: 'like' })
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(limit)
                .lean();

            const total = await Like.countDocuments({ likedId: userId, status: 'like' });

            return {
                likes,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit)
                }
            };
        } catch (error) {
            logger.error('Error getting user likers:', error);
            throw error;
        }
    }

    /**
     * Get mutual likes (matches)
     */
    async getMutualLikes(userId, options = {}) {
        try {
            const {
                page = 1,
                limit = 20
            } = options;

            const skip = (page - 1) * limit;

            // Get all users that this user liked
            const userLikes = await Like.find({ likerId: userId, status: 'like' })
                .select('likedId')
                .lean();

            const likedUserIds = userLikes.map(like => like.likedId);

            // Find mutual likes
            const mutualLikes = await Like.find({
                likerId: { $in: likedUserIds },
                likedId: userId,
                status: 'like'
            })
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(limit)
                .lean();

            const total = await Like.countDocuments({
                likerId: { $in: likedUserIds },
                likedId: userId,
                status: 'like'
            });

            return {
                matches: mutualLikes,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit)
                }
            };
        } catch (error) {
            logger.error('Error getting mutual likes:', error);
            throw error;
        }
    }

    /**
     * Check if two users have mutual like
     */
    async checkMutualLike(userId1, userId2) {
        try {
            return await Like.checkMutualLike(userId1, userId2);
        } catch (error) {
            logger.error('Error checking mutual like:', error);
            throw error;
        }
    }

    /**
     * Get like status between two users
     */
    async getLikeStatus(userId1, userId2) {
        try {
            const like1 = await Like.findOne({ likerId: userId1, likedId: userId2 });
            const like2 = await Like.findOne({ likerId: userId2, likedId: userId1 });

            return {
                userLiked: like1 ? like1.status : null,
                otherUserLiked: like2 ? like2.status : null,
                isMutual: !!(like1 && like2 && like1.status === 'like' && like2.status === 'like')
            };
        } catch (error) {
            logger.error('Error getting like status:', error);
            throw error;
        }
    }
}

module.exports = new LikeService();
