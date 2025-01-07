import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService extends ChangeNotifier {
  late IO.Socket socket;
  final StreamController<String> _messagesController = StreamController<String>.broadcast();

  String? username; 

  Stream<String> get messages => _messagesController.stream;

  WebSocketService(String url) {
    connect(url);
  }

  void connect(String url) {
    try {
      socket = IO.io(
        url,
        IO.OptionBuilder().setTransports(['websocket']).build(),
      );

      socket.onConnect((_) {
        print('Connected to Socket.IO server at $url');
        if (username != null) {
          setUsername(username!); 
        }
      });
      socket.onConnectError((error) => print('Connection Error: $error'));
      socket.onDisconnect((_) => print('Disconnected from server'));
      socket.onReconnect((_) => print('Reconnected to server'));

      socket.on('message', (data) {
        print("Message received: $data");
        _messagesController.add(data);
      });

      socket.on('chat-history', (data) {
        for (var message in data) {
          _messagesController.add(message['message']);
        }
      });
    } catch (e) {
      print('Socket.IO connection error: $e');
    }
  }

  void setUsername(String username) {
    this.username = username;
    if (socket.connected) {
      socket.emit('set-username', username);
      print('Username set: $username');
    } else {
      print('Socket is not connected. Username cannot be set now.');
    }
  }

  void connectToRoom(String roomCode) {
    if (socket.connected) {
      socket.emit('join-room', {'roomName': roomCode});
      print("Connected to room: $roomCode");
    } else {
      print('Socket is not connected. Cannot join room.');
    }
  }

  void sendMessage(String roomCode, String message) {
    if (socket.connected) {
      socket.emit('message', {
        'roomName': roomCode,
        'message': message,
      });
      print("Message sent: $message");
    } else {
      print('Socket is not connected.');
    }
  }

  void leaveRoom(String roomCode) {
    socket.emit('leave-room', {'roomName': roomCode});
  }

  @override
  void dispose() {
    socket.dispose();
    _messagesController.close();
    super.dispose();
  }
}
