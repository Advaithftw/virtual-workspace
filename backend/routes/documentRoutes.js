const express = require('express');
const router = express.Router();

router.get('/:roomCode', (req, res) => {
  const { roomCode } = req.params;
  res.status(200).send({ message: `Accessing room ${roomCode}` });
});


const setupDocumentSocket = (wss) => {
  const rooms = {};

  wss.on('connection', (ws, req) => {
    const roomCode = req.url.split('/').pop(); 
    if (!rooms[roomCode]) {
      rooms[roomCode] = [];
    }
    rooms[roomCode].push(ws);

    ws.on('message', (message) => {
      rooms[roomCode].forEach((client) => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(message);
        }
      });
    });

    ws.on('close', () => {
      rooms[roomCode] = rooms[roomCode].filter((client) => client !== ws);
    });
  });
};

module.exports = { router, setupDocumentSocket };
