const express = require('express');
const router = express.Router();
const { createRoom } = require('../controllers/chatcontroller');

router.post('/create-room', createRoom);


router.post('/', (req, res) => {
  res.status(200).send('Message received');
});

module.exports = router;
