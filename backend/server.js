require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/dbConfig');
const { initSocket } = require('./config/socketConfig');

dotenv.config();

connectDB();

const app = express();
const server = http.createServer(app);
initSocket(server);

const io = socketIO(server, {
  cors: {
    origin: '*', 
    methods: ['GET', 'POST'], 
  },
});

app.use(cors()); 
app.use(express.json()); 


app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/files', require('./routes/fileRoutes')); 
app.use('/api/chat', require('./routes/chatRoutes')); 

const rooms = {};

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

 
  socket.on('join-room', (roomCode) => {
    if (!rooms[roomCode]) {
      rooms[roomCode] = [];
    }

    rooms[roomCode].push(socket.id); 
    socket.join(roomCode); 

    console.log(`User ${socket.id} joined room ${roomCode}`);
    

    io.to(roomCode).emit('message', `${socket.id} has joined the room`);

    socket.emit('message', `Welcome to room ${roomCode}`);
  });

  socket.on('leave-room', (roomCode) => {
    if (rooms[roomCode]) {
      rooms[roomCode] = rooms[roomCode].filter((id) => id !== socket.id); 
      socket.leave(roomCode); 

      console.log(`User ${socket.id} left room ${roomCode}`);
      io.to(roomCode).emit('message', `${socket.id} has left the room`);
    }
  });


  socket.on('message', (data) => {
    const { roomCode, message } = data;

    if (rooms[roomCode]) {
      console.log(`Message in room ${roomCode}: ${message}`);
      io.to(roomCode).emit('message', message); 
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);

    
    for (let roomCode in rooms) {
      rooms[roomCode] = rooms[roomCode].filter((id) => id !== socket.id);
    }
  });
});


const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
