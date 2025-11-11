// routes/upload.routes.js
const express = require('express');
const router = express.Router();
const Joi = require('joi');
const uploadController = require('../controllers/upload.controller');
const { authenticateUser } = require('../middleware');
const { validateQuery } = require('../middleware/joi.middleware');
const {
    uploadSingleFile,
    uploadMultipleFiles,
    uploadSingleImage,
    uploadMultipleImages
} = require('../middleware/upload.middleware');

/**
 * Upload Routes
 * Base path: /api/v1/uploads
 */

// Upload single file (any type)
router.post(
    '/file',
    authenticateUser,
    ...uploadSingleFile('file'),
    uploadController.uploadFile
);

// Upload multiple files
router.post(
    '/files',
    authenticateUser,
    ...uploadMultipleFiles('files', 5),
    uploadController.uploadFiles
);

// Upload single image
router.post(
    '/image',
    authenticateUser,
    ...uploadSingleImage('image'),
    uploadController.uploadImage
);

// Upload multiple images
router.post(
    '/images',
    authenticateUser,
    ...uploadMultipleImages('images', 5),
    uploadController.uploadImages
);

// Delete file
router.delete(
    '/:filename',
    authenticateUser,
    validateQuery(Joi.object({ type: Joi.string().valid('image', 'video', 'audio', 'file').required() })),
    uploadController.deleteFile
);

module.exports = router;
