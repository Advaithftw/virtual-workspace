const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  roomCode: String,
  sender: String,
  message: String,
  timestamp: { type: Date, default: Date.now },
});

const Message = mongoose.model('Message', MessageSchema);
module.exports = Message;
