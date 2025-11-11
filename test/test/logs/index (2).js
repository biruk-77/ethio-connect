// services/index.js
const messageService = require('./message.service');
const userService = require('./user.service');
const notificationService = require('./notification.service');
const commentService = require('./comment.service');
const socketService = require('./socket.service');

module.exports = {
    messageService,
    userService,
    notificationService,
    commentService,
    socketService
};
