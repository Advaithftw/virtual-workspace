const WebSocket = require('ws');
const wss = new WebSocket.Server({ noServer: true });
const rooms = {}; 
wss.on('connection', (ws) => {
  let currentRoom = null;

  ws.on('message', (message) => {
    const parsedMessage = JSON.parse(message);

   
    if (parsedMessage.action === 'JOIN') {
      const roomCode = parsedMessage.roomCode;

      if (!rooms[roomCode]) {
        rooms[roomCode] = [];
      }

      rooms[roomCode].push(ws);
      currentRoom = roomCode;
      ws.send(JSON.stringify({ action: 'joined', roomCode }));

      broadcastToRoom(roomCode, `${ws._socket.remoteAddress} joined the room`);
    }
    if (parsedMessage.action === 'MESSAGE' && currentRoom) {
      broadcastToRoom(currentRoom, parsedMessage.message);
    }
  });

  ws.on('close', () => {
    if (currentRoom) {
      const index = rooms[currentRoom].indexOf(ws);
      if (index !== -1) {
        rooms[currentRoom].splice(index, 1);
        broadcastToRoom(currentRoom, `${ws._socket.remoteAddress} left the room`);
      }
    }
  });
});

function broadcastToRoom(roomCode, message) {
  const clients = rooms[roomCode];
  if (clients) {
    clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ action: 'message', message })); 
      }
    });
  }
}

module.exports = wss;
