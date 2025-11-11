// services/favorite.service.js
const Favorite = require('../models/Favorite.model');
const logger = require('../config/logger.config');

/**
 * Favorite Service - Manages favorites for posts and profiles
 */
class FavoriteService {
    /**
     * Add favorite
     */
    async addFavorite(userId, targetType, targetId) {
        try {
            if (!['Post', 'Profile'].includes(targetType)) {
                throw new Error('Invalid target type. Must be Post or Profile');
            }

            const favorite = await Favorite.create({
                userId,
                targetType,
                targetId
            });

            logger.info(`User ${userId} favorited ${targetType} ${targetId}`);
            return favorite;
        } catch (error) {
            if (error.code === 11000) {
                // Duplicate key error - already favorited
                throw new Error('Already favorited');
            }
            logger.error('Error adding favorite:', error);
            throw error;
        }
    }

    /**
     * Remove favorite
     */
    async removeFavorite(userId, targetType, targetId) {
        try {
            const result = await Favorite.deleteOne({
                userId,
                targetType,
                targetId
            });

            logger.info(`User ${userId} unfavorited ${targetType} ${targetId}`);
            return result;
        } catch (error) {
            logger.error('Error removing favorite:', error);
            throw error;
        }
    }

    /**
     * Toggle favorite
     */
    async toggleFavorite(userId, targetType, targetId) {
        try {
            const existing = await Favorite.findOne({ userId, targetType, targetId });

            if (existing) {
                await existing.deleteOne();
                return {
                    action: 'removed',
                    isFavorited: false
                };
            } else {
                await this.addFavorite(userId, targetType, targetId);
                return {
                    action: 'added',
                    isFavorited: true
                };
            }
        } catch (error) {
            logger.error('Error toggling favorite:', error);
            throw error;
        }
    }

    /**
     * Get user's favorites
     */
    async getUserFavorites(userId, targetType = null, options = {}) {
        try {
            return await Favorite.getUserFavorites(userId, targetType, options);
        } catch (error) {
            logger.error('Error getting user favorites:', error);
            throw error;
        }
    }

    /**
     * Check if favorited
     */
    async isFavorited(userId, targetType, targetId) {
        try {
            return await Favorite.isFavorited(userId, targetType, targetId);
        } catch (error) {
            logger.error('Error checking if favorited:', error);
            throw error;
        }
    }

    /**
     * Get favorite count for target
     */
    async getFavoriteCount(targetType, targetId) {
        try {
            return await Favorite.getFavoriteCount(targetType, targetId);
        } catch (error) {
            logger.error('Error getting favorite count:', error);
            throw error;
        }
    }

    /**
     * Get favorites with details
     */
    async getUserFavoritesWithDetails(userId, targetType = null, options = {}) {
        try {
            const result = await this.getUserFavorites(userId, targetType, options);
            
            // Group by target type
            const grouped = {
                posts: [],
                profiles: []
            };

            result.favorites.forEach(fav => {
                if (fav.targetType === 'Post') {
                    grouped.posts.push(fav.targetId);
                } else if (fav.targetType === 'Profile') {
                    grouped.profiles.push(fav.targetId);
                }
            });

            return {
                ...result,
                grouped
            };
        } catch (error) {
            logger.error('Error getting favorites with details:', error);
            throw error;
        }
    }

    /**
     * Bulk check favorites
     */
    async checkMultipleFavorites(userId, targets) {
        try {
            const checks = await Promise.all(
                targets.map(async ({ targetType, targetId }) => {
                    const isFavorited = await this.isFavorited(userId, targetType, targetId);
                    return {
                        targetType,
                        targetId,
                        isFavorited
                    };
                })
            );

            return checks;
        } catch (error) {
            logger.error('Error checking multiple favorites:', error);
            throw error;
        }
    }
}

module.exports = new FavoriteService();
