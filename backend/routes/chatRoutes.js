const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');


router.post('/createRoom', chatController.createRoom);

router.post('/sendMessage', chatController.sendMessage);

router.get('/joinRoom/:roomCode', chatController.joinRoom);


module.exports = router;
