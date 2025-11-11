// routes/comment.routes.js
const express = require('express');
const router = express.Router();
const { commentController } = require('../controllers');
const { authenticateUser } = require('../middleware/auth.middleware');
const { validate, commentValidators } = require('../validators/comment.validator');

/**
 * @route   POST /api/v1/comments
 * @desc    Create a new comment
 * @access  Private
 */
router.post(
    '/',
    authenticateUser,
    validate(commentValidators.createComment),
    commentController.createComment
);

/**
 * @route   GET /api/v1/comments/:targetType/:targetId
 * @desc    Get comments for a target (Post or Profile)
 * @access  Public
 */
router.get(
    '/:targetType/:targetId',
    validate(commentValidators.targetParams, 'params'),
    validate(commentValidators.paginationQuery, 'query'),
    commentController.getTargetComments
);

/**
 * @route   GET /api/v1/comments/:commentId
 * @desc    Get a single comment by ID
 * @access  Public
 */
router.get(
    '/:commentId',
    validate(commentValidators.commentId, 'params'),
    commentController.getComment
);

/**
 * @route   GET /api/v1/comments/:commentId/replies
 * @desc    Get replies to a comment
 * @access  Public
 */
router.get(
    '/:commentId/replies',
    validate(commentValidators.commentId, 'params'),
    validate(commentValidators.paginationQuery, 'query'),
    commentController.getCommentReplies
);

/**
 * @route   GET /api/v1/comments/:commentId/thread
 * @desc    Get comment thread (comment with all replies)
 * @access  Public
 */
router.get(
    '/:commentId/thread',
    validate(commentValidators.commentId, 'params'),
    validate(commentValidators.paginationQuery, 'query'),
    commentController.getCommentThread
);

/**
 * @route   GET /api/v1/comments/user/:userId
 * @desc    Get user's comments
 * @access  Public
 */
router.get(
    '/user/:userId',
    validate(commentValidators.userId, 'params'),
    validate(commentValidators.paginationQuery, 'query'),
    commentController.getUserComments
);

/**
 * @route   GET /api/v1/comments/stats/:targetType/:targetId
 * @desc    Get comment statistics for a target
 * @access  Public
 */
router.get(
    '/stats/:targetType/:targetId',
    validate(commentValidators.targetParams, 'params'),
    commentController.getCommentStats
);

/**
 * @route   PUT /api/v1/comments/:commentId
 * @desc    Update a comment
 * @access  Private
 */
router.put(
    '/:commentId',
    authenticateUser,
    validate(commentValidators.commentId, 'params'),
    validate(commentValidators.updateComment),
    commentController.updateComment
);

/**
 * @route   DELETE /api/v1/comments/:commentId
 * @desc    Delete a comment
 * @access  Private
 */
router.delete(
    '/:commentId',
    authenticateUser,
    validate(commentValidators.commentId, 'params'),
    commentController.deleteComment
);

/**
 * @route   PATCH /api/v1/comments/:commentId/moderate
 * @desc    Moderate a comment (admin only)
 * @access  Private (Admin)
 */
router.patch(
    '/:commentId/moderate',
    authenticateUser,
    // TODO: Add admin role check middleware
    validate(commentValidators.commentId, 'params'),
    validate(commentValidators.moderateComment),
    commentController.moderateComment
);

module.exports = router;
