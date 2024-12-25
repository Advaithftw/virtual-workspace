const Message = require('../models/Message');
const User = require('../models/User');
const { io } = require('../config/socketConfig');

exports.sendMessage = async (req, res) => {
  try {
    const { senderId, recipientId, message } = req.body;

    if (!message || !senderId || !recipientId) {
      return res.status(400).json({ error: 'Message, sender, and recipient are required' });
    }

    const sender = await User.findById(senderId);
    const recipient = await User.findById(recipientId);
    
    if (!sender || !recipient) {
      return res.status(404).json({ error: 'Sender or recipient not found' });
    }

    const newMessage = new Message({
      sender: senderId,
      recipient: recipientId,
      message,
    });

    await newMessage.save();

    io.to(recipientId).emit('chat message', {
      sender: sender.username,
      message: newMessage.message,
      timestamp: newMessage.timestamp,
    });

    res.status(200).json({
      message: 'Message sent successfully',
      data: newMessage,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to send message' });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const { user1Id, user2Id } = req.params;

    const messages = await Message.find({
      $or: [
        { sender: user1Id, recipient: user2Id },
        { sender: user2Id, recipient: user1Id },
      ],
    }).sort({ timestamp: 1 });

    res.status(200).json({
      messages,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to retrieve messages' });
  }
};
