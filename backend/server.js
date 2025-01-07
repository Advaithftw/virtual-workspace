require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const cors = require('cors');
const session = require('express-session');
const passport = require('./config/passportConfig');
const dotenv = require('dotenv');
const connectDB = require('./config/dbConfig');
const AWS = require('aws-sdk');
const multer = require('multer');
const upload = multer();


dotenv.config();


connectDB();

const app = express();
const server = http.createServer(app);

const io = socketIO(server, {
  cors: {
    origin: '*', 
    methods: ['GET', 'POST'],
  },
});

const s3 = new AWS.S3();


app.use(cors());
app.use(express.json());


app.use(
  session({
    secret: process.env.SESSION_SECRET || 'yourSecretKey', 
    resave: false,
    saveUninitialized: false, 
    cookie: { secure: false }, 
  })
);


app.use(passport.initialize());
app.use(passport.session());


app.use('/api/auth', require('./routes/authRoutes')); 
app.use('/api/files', require('./routes/fileRoutes'));
app.use('/api/chat', require('./routes/chatRoutes')); 


const rooms = {};
const documents = {}; 

app.post('/api/files/upload', upload.single('file'), (req, res) => {
  const params = {
    Bucket: process.env.S3_BUCKET,
    Key: req.file.originalname,
    Body: req.file.buffer,
  };

  s3.upload(params, (err, data) => {
    if (err) return res.status(500).send(err);

    const roomCode = req.body.roomCode;
    if (roomCode) {
      io.to(roomCode).emit('file-uploaded', { url: data.Location, fileName: req.file.originalname });
    }

    res.json({ message: 'File uploaded successfully', url: data.Location });
  });
});

app.get('/api/document/:roomCode', (req, res) => {
  const { roomCode } = req.params;
  const document = documents[roomCode] || { content: '' };
  res.json(document);
});

app.post('/api/document/:roomCode', (req, res) => {
  const { roomCode } = req.params;
  const { content } = req.body;

  if (!content) {
    return res.status(400).send({ error: 'Content is required' });
  }

  documents[roomCode] = { content };
  io.to(roomCode).emit('document-updated', content); 
  res.json({ message: 'Document saved successfully' });
});


io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join-document', (roomCode) => {
    if (!roomCode) {
      return socket.emit('error', 'Room code is required');
    }

    if (!documents[roomCode]) {
      documents[roomCode] = { content: '' }; 
    }

    socket.join(roomCode);
    console.log(`User ${socket.id} joined document room ${roomCode}`);

    socket.emit('document-content', documents[roomCode].content);
  });

  socket.on('edit-document', ({ roomCode, content }) => {
    if (!roomCode || !content) {
      return socket.emit('error', 'Room code and content are required');
    }

    if (documents[roomCode]) {
      documents[roomCode].content = content; 
      socket.to(roomCode).emit('document-updated', content);
    } else {
      socket.emit('error', 'Invalid room code');
    }
  });

  socket.on('join-room', (roomCode) => {
    if (!roomCode) {
      return socket.emit('error', 'Room code is required');
    }

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
    if (!roomCode) {
      return socket.emit('error', 'Room code is required');
    }

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
