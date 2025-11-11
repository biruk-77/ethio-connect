// services/notification.service.js
const admin = require('firebase-admin');
const Notification = require('../models/Notification.model');
const User = require('../models/User.model');
const logger = require('../config/logger.config');
const { AppError } = require('../middleware/error.middleware');

/**
 * Notification Service - Handles in-app and push notifications
 */
class NotificationService {
    /**
     * Send notification (in-app + push fallback)
     */
    async sendNotification(userId, notificationData, io) {
        try {
            const { type, title, body, data = {}, senderId, priority = 'normal', actionUrl } = notificationData;

            logger.info(`Sending notification to user ${userId}, type: ${type}`);

            // Convert firebaseUid (UUID string) to MongoDB ObjectId
            let userObjectId = userId;
            let senderObjectId = senderId;
            
            // If userId is a UUID string (contains hyphens), look up the MongoDB ObjectId
            if (typeof userId === 'string' && userId.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)) {
                logger.info(`Looking up user with firebaseUid: ${userId}`);
                try {
                    const user = await User.findOne({ firebaseUid: userId }).select('_id').lean();
                    if (!user) {
                        logger.warn(`User not found for firebaseUid: ${userId}`);
                        return null;
                    }
                    userObjectId = user._id;
                    logger.info(`Converted firebaseUid ${userId} to ObjectId ${userObjectId}`);
                } catch (err) {
                    logger.error(`Error looking up user: ${err.message}`);
                    throw err;
                }
            }
            
            // Same for senderId
            if (senderId && typeof senderId === 'string' && senderId.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)) {
                const sender = await User.findOne({ firebaseUid: senderId }).select('_id');
                if (sender) {
                    senderObjectId = sender._id;
                    logger.info(`Converted sender firebaseUid ${senderId} to ObjectId ${senderObjectId}`);
                }
            }

            // Create notification record
            const notification = await Notification.create({
                userId: userObjectId,
                type,
                title,
                body,
                data,
                senderId: senderObjectId,
                priority,
                actionUrl,
                deliveryStatus: {
                    inApp: false,
                    push: false,
                    sentAt: new Date()
                }
            });

            // Attempt in-app notification via Socket.IO
            let inAppDelivered = false;
            if (io) {
                const socketDelivered = io.to(`user_${userId}`).emit('notification', {
                    notification: notification.toJSON(),
                    timestamp: new Date()
                });
                
                // Check if user is connected (has active sockets)
                const userRoom = io.sockets.adapter.rooms.get(`user_${userId}`);
                inAppDelivered = userRoom && userRoom.size > 0;
                
                notification.deliveryStatus.inApp = inAppDelivered;
            }

            // Send push notification if in-app delivery failed or user offline
            if (!inAppDelivered) {
                logger.info(`User ${userObjectId} offline, sending push notification`);
                await this.sendPushNotification(userObjectId, {
                    title,
                    body,
                    data: {
                        ...data,
                        notificationId: notification.id,
                        type,
                        actionUrl
                    },
                    priority
                });
                notification.deliveryStatus.push = true;
            }

            await notification.save();

            logger.info(`Notification sent successfully: ${notification.id}, inApp: ${inAppDelivered}, push: ${!inAppDelivered}`);

            return notification;
        } catch (error) {
            logger.error('Error sending notification:', error);
            throw error;
        }
    }

    /**
     * Send push notification via FCM
     */
    async sendPushNotification(userId, { title, body, data = {}, priority = 'normal' }) {
        try {
            // Get user's FCM tokens
            const user = await User.findById(userId).select('fcmTokens');
            
            if (!user || !user.fcmTokens || user.fcmTokens.length === 0) {
                logger.warn(`No FCM tokens found for user ${userId}`);
                return { success: false, reason: 'no_tokens' };
            }

            const tokens = user.fcmTokens.map(t => t.token);

            // Prepare FCM message
            const message = {
                notification: {
                    title,
                    body
                },
                data: {
                    ...data,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK'
                },
                android: {
                    priority: priority === 'high' ? 'high' : 'normal',
                    notification: {
                        sound: 'default',
                        channelId: 'default'
                    }
                },
                apns: {
                    payload: {
                        aps: {
                            alert: {
                                title,
                                body
                            },
                            sound: 'default',
                            badge: await Notification.getUnreadCount(userId)
                        }
                    }
                },
                tokens
            };

            // Send multicast message
            const response = await admin.messaging().sendEachForMulticast(message);

            logger.info(`FCM sent: ${response.successCount}/${tokens.length} successful, ${response.failureCount} failed`);

            // Remove invalid tokens
            if (response.failureCount > 0) {
                const invalidTokens = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        const errorCode = resp.error?.code;
                        if (
                            errorCode === 'messaging/invalid-registration-token' ||
                            errorCode === 'messaging/registration-token-not-registered'
                        ) {
                            invalidTokens.push(tokens[idx]);
                        }
                    }
                });

                if (invalidTokens.length > 0) {
                    await this.removeInvalidTokens(userId, invalidTokens);
                }
            }

            return {
                success: true,
                successCount: response.successCount,
                failureCount: response.failureCount
            };
        } catch (error) {
            logger.error('Error sending push notification:', error);
            throw error;
        }
    }

    /**
     * Send notification to multiple users
     */
    async sendBulkNotifications(userIds, notificationData, io) {
        const results = await Promise.allSettled(
            userIds.map(userId => this.sendNotification(userId, notificationData, io))
        );

        const successful = results.filter(r => r.status === 'fulfilled').length;
        const failed = results.filter(r => r.status === 'rejected').length;

        logger.info(`Bulk notifications: ${successful} successful, ${failed} failed`);

        return { successful, failed, results };
    }

    /**
     * Send new message notification
     */
    async sendMessageNotification(receiverId, message, sender, io) {
        return this.sendNotification(
            receiverId,
            {
                type: 'message',
                title: `New message from ${sender.displayName || sender.username}`,
                body: message.messageType === 'text' 
                    ? message.content.substring(0, 100)
                    : `Sent a ${message.messageType}`,
                data: {
                    messageId: message.id,
                    senderId: sender.id,
                    conversationId: message.conversationId
                },
                senderId: sender.id,
                actionUrl: `/messages/${sender.id}`,
                priority: 'high'
            },
            io
        );
    }

    // ============================================================
    // CONNECTION NOTIFICATIONS - NOT REQUIRED FOR MARKETPLACE
    // Connections are managed by User Service
    // ============================================================

    /**
     * Send connection request notification
     * NOTE: This is triggered by User Service via socket events
     */
    async sendConnectionRequestNotification(receiverId, connection, requester, io) {
        return this.sendNotification(
            receiverId,
            {
                type: 'connection_request',
                title: 'New Connection Request',
                body: `${requester.displayName || requester.username} wants to connect with you`,
                data: {
                    connectionId: connection.id,
                    requesterId: requester.id,
                    requesterUsername: requester.username
                },
                priority: 'high',
                actionUrl: `/connections/requests`
            },
            io
        );
    }

    /**
     * Send connection accepted notification
     * NOTE: This is triggered by User Service via socket events
     */
    async sendConnectionAcceptedNotification(requesterId, connection, accepter, io) {
        return this.sendNotification(
            requesterId,
            {
                type: 'connection_accepted',
                title: 'Connection Accepted',
                body: `${accepter.displayName || accepter.username} accepted your connection request`,
                data: {
                    connectionId: connection.id,
                    accepterId: accepter.id,
                    accepterUsername: accepter.username
                },
                priority: 'high',
                actionUrl: `/profile/${accepter.username}`
            },
            io
        );
    }

    /**
     * Send post like notification
     */
    async sendPostLikeNotification(postOwnerId, post, liker, io) {
        // Don't notify if user likes their own post
        if (postOwnerId === liker.id) {
            return null;
        }

        return this.sendNotification(
            postOwnerId,
            {
                type: 'post_like',
                title: 'New Like',
                body: `${liker.displayName || liker.username} liked your post`,
                data: {
                    postId: post.id || post._id,
                    likerId: liker.id,
                    postPreview: post.content ? post.content.substring(0, 50) : ''
                },
                senderId: liker.id,
                actionUrl: `/posts/${post.id || post._id}`,
                priority: 'low'
            },
            io
        );
    }

    /**
     * Send post comment notification
     */
    async sendPostCommentNotification(postOwnerId, comment, commenter, io) {
        // Don't notify if user comments on their own post
        if (postOwnerId === commenter.id) {
            return null;
        }

        return this.sendNotification(
            postOwnerId,
            {
                type: 'post_comment',
                title: 'New Comment',
                body: `${commenter.displayName || commenter.username} commented on your post`,
                data: {
                    postId: comment.targetId,
                    commentId: comment.id || comment._id,
                    commenterId: commenter.id,
                    commentPreview: comment.content ? comment.content.substring(0, 100) : ''
                },
                senderId: commenter.id,
                actionUrl: `/posts/${comment.targetId}#comment-${comment.id || comment._id}`,
                priority: 'normal'
            },
            io
        );
    }

    /**
     * Send comment reply notification
     */
    async sendCommentReplyNotification(commentOwnerId, reply, replier, io) {
        // Don't notify if user replies to their own comment
        if (commentOwnerId === replier.id) {
            return null;
        }

        return this.sendNotification(
            commentOwnerId,
            {
                type: 'comment_reply',
                title: 'New Reply',
                body: `${replier.displayName || replier.username} replied to your comment`,
                data: {
                    postId: reply.targetId,
                    commentId: reply.parentId,
                    replyId: reply.id || reply._id,
                    replierId: replier.id,
                    replyPreview: reply.content ? reply.content.substring(0, 100) : ''
                },
                senderId: replier.id,
                actionUrl: `/posts/${reply.targetId}#comment-${reply.id || reply._id}`,
                priority: 'normal'
            },
            io
        );
    }

    /**
     * Send post share notification
     */
    async sendPostShareNotification(postOwnerId, post, sharer, io) {
        // Don't notify if user shares their own post
        if (postOwnerId === sharer.id) {
            return null;
        }

        return this.sendNotification(
            postOwnerId,
            {
                type: 'post_share',
                title: 'Post Shared',
                body: `${sharer.displayName || sharer.username} shared your post`,
                data: {
                    postId: post.id || post._id,
                    sharerId: sharer.id,
                    postPreview: post.content ? post.content.substring(0, 50) : ''
                },
                senderId: sharer.id,
                actionUrl: `/posts/${post.id || post._id}`,
                priority: 'low'
            },
            io
        );
    }

    /**
     * Send mention notification
     */
    async sendMentionNotification(mentionedUserId, content, mentioner, contentType, contentId, io) {
        return this.sendNotification(
            mentionedUserId,
            {
                type: 'mention',
                title: 'You were mentioned',
                body: `${mentioner.displayName || mentioner.username} mentioned you in a ${contentType}`,
                data: {
                    contentType, // 'post' or 'comment'
                    contentId,
                    mentionerId: mentioner.id,
                    contentPreview: content ? content.substring(0, 100) : ''
                },
                senderId: mentioner.id,
                actionUrl: contentType === 'post' 
                    ? `/posts/${contentId}` 
                    : `/posts/${contentId.postId}#comment-${contentId.commentId}`,
                priority: 'high'
            },
            io
        );
    }

    /**
     * Send post interaction notification (generic for other interactions)
     */
    async sendPostInteractionNotification(userId, interactionType, post, actor, io) {
        const titles = {
            'bookmark': 'Post Bookmarked',
            'save': 'Post Saved',
            'report': 'Post Reported'
        };

        const bodies = {
            'bookmark': `${actor.displayName || actor.username} bookmarked your post`,
            'save': `${actor.displayName || actor.username} saved your post`,
            'report': `Your post was reported`
        };

        return this.sendNotification(
            userId,
            {
                type: `post_${interactionType}`,
                title: titles[interactionType] || 'Post Interaction',
                body: bodies[interactionType] || `${actor.displayName || actor.username} interacted with your post`,
                data: {
                    postId: post.id || post._id,
                    actorId: actor.id,
                    interactionType
                },
                senderId: actor.id,
                actionUrl: `/posts/${post.id || post._id}`,
                priority: interactionType === 'report' ? 'high' : 'low'
            },
            io
        );
    }

    /**
     * Get user notifications
     */
    async getUserNotifications(userId, options = {}) {
        const notifications = await Notification.getUserNotifications(userId, options);
        const unreadCount = await Notification.getUnreadCount(userId);

        return {
            notifications,
            unreadCount,
            total: notifications.length
        };
    }

    /**
     * Mark notification as read
     */
    async markAsRead(notificationId, userId) {
        const notification = await Notification.findOne({ _id: notificationId, userId });

        if (!notification) {
            throw new AppError('Notification not found', 404);
        }

        if (notification.read) {
            return notification;
        }

        return notification.markAsRead();
    }

    /**
     * Mark all notifications as read
     */
    async markAllAsRead(userId) {
        const result = await Notification.markAllAsRead(userId);
        logger.info(`Marked ${result.modifiedCount} notifications as read for user ${userId}`);
        return result.modifiedCount;
    }

    /**
     * Delete notification
     */
    async deleteNotification(notificationId, userId) {
        const notification = await Notification.findOneAndDelete({ _id: notificationId, userId });

        if (!notification) {
            throw new AppError('Notification not found', 404);
        }

        logger.info(`Notification deleted: ${notificationId}`);
        return notification;
    }

    /**
     * Get unread count
     */
    async getUnreadCount(userId) {
        return Notification.getUnreadCount(userId);
    }

    /**
     * Remove invalid FCM tokens
     */
    async removeInvalidTokens(userId, invalidTokens) {
        try {
            const user = await User.findById(userId);
            if (!user) return;

            user.fcmTokens = user.fcmTokens.filter(t => !invalidTokens.includes(t.token));
            await user.save();

            logger.info(`Removed ${invalidTokens.length} invalid FCM tokens for user ${userId}`);
        } catch (error) {
            logger.error('Error removing invalid tokens:', error);
        }
    }

    /**
     * Clear old notifications (cleanup job)
     */
    async clearOldNotifications(daysOld = 30) {
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - daysOld);

        const result = await Notification.deleteMany({
            createdAt: { $lt: cutoffDate },
            read: true
        });

        logger.info(`Cleared ${result.deletedCount} old notifications`);
        return result.deletedCount;
    }

    /**
     * Send mass notification to all users
     */
    async sendMassNotification(notificationData, io, options = {}) {
        try {
            const { excludeUserIds = [], activeOnly = true } = options;

            logger.info('Sending mass notification to all users');

            // Get all users (excluding specified ones)
            const query = { isActive: activeOnly };
            if (excludeUserIds.length > 0) {
                query._id = { $nin: excludeUserIds };
            }

            const users = await User.find(query).select('_id fcmTokens');
            const userIds = users.map(u => u._id.toString());

            logger.info(`Sending mass notification to ${userIds.length} users`);

            // Send notifications in batches to avoid overwhelming the system
            const batchSize = 100;
            let totalSent = 0;
            let totalFailed = 0;

            for (let i = 0; i < userIds.length; i += batchSize) {
                const batch = userIds.slice(i, i + batchSize);
                
                const results = await Promise.allSettled(
                    batch.map(userId => this.sendNotification(userId, notificationData, io))
                );

                const successful = results.filter(r => r.status === 'fulfilled').length;
                const failed = results.filter(r => r.status === 'rejected').length;

                totalSent += successful;
                totalFailed += failed;

                logger.info(`Batch ${Math.floor(i / batchSize) + 1}: ${successful} sent, ${failed} failed`);
            }

            logger.info(`Mass notification complete: ${totalSent} sent, ${totalFailed} failed`);

            return {
                success: true,
                totalUsers: userIds.length,
                sent: totalSent,
                failed: totalFailed
            };
        } catch (error) {
            logger.error('Error sending mass notification:', error);
            throw error;
        }
    }

    /**
     * Send targeted notification based on criteria
     */
    async sendTargetedNotification(criteria, notificationData, io) {
        try {
            logger.info('Sending targeted notification', { criteria });

            // Build query based on criteria
            const query = { isActive: true };

            if (criteria.userIds && criteria.userIds.length > 0) {
                query._id = { $in: criteria.userIds };
            }

            if (criteria.status) {
                query.status = criteria.status; // online, offline, etc.
            }

            // NOTE: Connection-based targeting not available in marketplace mode
            // Connections are managed by User Service
            // if (criteria.minConnections) {
            //     const Connection = require('../models/Connection.model');
            //     const userIdsWithConnections = await Connection.aggregate([
            //         { $match: { status: 'accepted' } },
            //         {
            //             $group: {
            //                 _id: '$requesterId',
            //                 connectionCount: { $sum: 1 }
            //             }
            //         },
            //         { $match: { connectionCount: { $gte: criteria.minConnections } } },
            //         { $project: { _id: 1 } }
            //     ]);
            //     
            //     const validUserIds = userIdsWithConnections.map(u => u._id);
            //     query._id = query._id 
            //         ? { $in: query._id.$in.filter(id => validUserIds.includes(id)) }
            //         : { $in: validUserIds };
            // }

            if (criteria.createdAfter) {
                query.createdAt = { $gte: new Date(criteria.createdAfter) };
            }

            if (criteria.createdBefore) {
                query.createdAt = { 
                    ...query.createdAt,
                    $lte: new Date(criteria.createdBefore) 
                };
            }

            // Get matching users
            const users = await User.find(query).select('_id');
            const userIds = users.map(u => u._id.toString());

            logger.info(`Found ${userIds.length} users matching criteria`);

            if (userIds.length === 0) {
                return {
                    success: true,
                    totalUsers: 0,
                    sent: 0,
                    failed: 0
                };
            }

            // Send notifications
            const results = await this.sendBulkNotifications(userIds, notificationData, io);

            logger.info(`Targeted notification complete: ${results.successful} sent, ${results.failed} failed`);

            return {
                success: true,
                totalUsers: userIds.length,
                sent: results.successful,
                failed: results.failed
            };
        } catch (error) {
            logger.error('Error sending targeted notification:', error);
            throw error;
        }
    }

    /**
     * Send notification to users in specific segments
     */
    async sendSegmentedNotification(segment, notificationData, io) {
        const criteria = {};

        switch (segment) {
            case 'active_users':
                // Users active in last 7 days
                criteria.lastSeen = { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) };
                break;

            case 'inactive_users':
                // Users inactive for more than 30 days
                criteria.lastSeen = { $lt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) };
                break;

            case 'new_users':
                // Users created in last 7 days
                criteria.createdAfter = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
                break;

            case 'online_users':
                // Currently online users
                criteria.status = 'online';
                break;

            default:
                throw new AppError(`Invalid segment: ${segment}`, 400);
        }

        return this.sendTargetedNotification(criteria, notificationData, io);
    }

    /**
     * Send FCM-only mass notification (bypass in-app)
     */
    async sendMassPushNotification(notificationData, options = {}) {
        try {
            const { excludeUserIds = [], activeOnly = true } = options;

            logger.info('Sending mass push notification');

            // Get all users with FCM tokens
            const query = { 
                isActive: activeOnly,
                'fcmTokens.0': { $exists: true } // Has at least one FCM token
            };
            
            if (excludeUserIds.length > 0) {
                query._id = { $nin: excludeUserIds };
            }

            const users = await User.find(query).select('fcmTokens');

            // Collect all FCM tokens
            const allTokens = [];
            users.forEach(user => {
                user.fcmTokens.forEach(tokenObj => {
                    allTokens.push(tokenObj.token);
                });
            });

            logger.info(`Sending push to ${allTokens.length} device tokens from ${users.length} users`);

            if (allTokens.length === 0) {
                return { success: true, sent: 0, failed: 0 };
            }

            const { title, body, data = {}, priority = 'normal' } = notificationData;

            // Send in batches (FCM allows max 500 tokens per request)
            const batchSize = 500;
            let totalSuccess = 0;
            let totalFailure = 0;

            for (let i = 0; i < allTokens.length; i += batchSize) {
                const batch = allTokens.slice(i, i + batchSize);

                const message = {
                    notification: { title, body },
                    data: {
                        ...data,
                        click_action: 'FLUTTER_NOTIFICATION_CLICK'
                    },
                    android: {
                        priority: priority === 'high' ? 'high' : 'normal',
                        notification: {
                            sound: 'default',
                            channelId: 'default'
                        }
                    },
                    apns: {
                        payload: {
                            aps: {
                                alert: { title, body },
                                sound: 'default'
                            }
                        }
                    },
                    tokens: batch
                };

                const response = await admin.messaging().sendEachForMulticast(message);
                totalSuccess += response.successCount;
                totalFailure += response.failureCount;

                logger.info(`Batch ${Math.floor(i / batchSize) + 1}: ${response.successCount}/${batch.length} successful`);
            }

            logger.info(`Mass push complete: ${totalSuccess} sent, ${totalFailure} failed`);

            return {
                success: true,
                totalTokens: allTokens.length,
                sent: totalSuccess,
                failed: totalFailure
            };
        } catch (error) {
            logger.error('Error sending mass push notification:', error);
            throw error;
        }
    }

    /**
     * Schedule notification (basic implementation)
     */
    async scheduleNotification(scheduledFor, userIds, notificationData, io) {
        const delay = new Date(scheduledFor).getTime() - Date.now();

        if (delay < 0) {
            throw new AppError('Scheduled time must be in the future', 400);
        }

        logger.info(`Scheduling notification for ${userIds.length} users at ${scheduledFor}`);

        setTimeout(async () => {
            try {
                await this.sendBulkNotifications(userIds, notificationData, io);
                logger.info(`Scheduled notification sent to ${userIds.length} users`);
            } catch (error) {
                logger.error('Error sending scheduled notification:', error);
            }
        }, delay);

        return {
            success: true,
            scheduledFor,
            userCount: userIds.length
        };
    }
}

module.exports = new NotificationService();
