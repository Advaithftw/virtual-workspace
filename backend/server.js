require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/dbConfig');
const { initSocket } = require('./config/socketConfig');

// Load environment variables
dotenv.config();

// Connect to the database
connectDB();

const app = express();
const server = http.createServer(app);
initSocket(server);

// Configure Socket.IO with CORS
const io = socketIO(server, {
  cors: {
    origin: '*', // Allow all origins
    methods: ['GET', 'POST'], // Allowed HTTP methods
  },
});

// Middleware
app.use(cors()); // Handle cross-origin requests
app.use(express.json()); // Parse incoming JSON requests

// Routes
app.use('/api/auth', require('./routes/authRoutes')); // Authentication routes
app.use('/api/files', require('./routes/fileRoutes')); // File management routes
app.use('/api/chat', require('./routes/chatRoutes')); // Chat-related routes

// In-memory rooms data structure
const rooms = {};

// Socket.IO Event Handlers
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Join room event
  socket.on('join-room', (roomCode) => {
    if (!rooms[roomCode]) {
      rooms[roomCode] = [];
    }

    rooms[roomCode].push(socket.id); // Add user to room
    socket.join(roomCode); // Join the room

    console.log(`User ${socket.id} joined room ${roomCode}`);
    
    // Notify other users in the room
    io.to(roomCode).emit('message', `${socket.id} has joined the room`);

    // Welcome message for the user
    socket.emit('message', `Welcome to room ${roomCode}`);
  });

  // Leave room event
  socket.on('leave-room', (roomCode) => {
    if (rooms[roomCode]) {
      rooms[roomCode] = rooms[roomCode].filter((id) => id !== socket.id); // Remove user from room
      socket.leave(roomCode); // Leave the room

      console.log(`User ${socket.id} left room ${roomCode}`);
      io.to(roomCode).emit('message', `${socket.id} has left the room`);
    }
  });

  // Handle chat messages
  socket.on('message', (data) => {
    const { roomCode, message } = data;

    if (rooms[roomCode]) {
      console.log(`Message in room ${roomCode}: ${message}`);
      io.to(roomCode).emit('message', message); // Broadcast message to the room
    }
  });

  // Handle user disconnection
  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);

    // Remove the user from all rooms
    for (let roomCode in rooms) {
      rooms[roomCode] = rooms[roomCode].filter((id) => id !== socket.id);
    }
  });
});

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
