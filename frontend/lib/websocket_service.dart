import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService extends ChangeNotifier {
  late IO.Socket socket;
  final StreamController<String> _messagesController = StreamController<String>.broadcast();

  Stream<String> get messages => _messagesController.stream;

  WebSocketService(String url) {
    connect(url);
  }

  void connect(String url) {
    try {
      socket = IO.io(url, IO.OptionBuilder()
          .setTransports(['websocket']) 
          .build());

      socket.onConnect((_) {
        print('Connected to Socket.IO server at $url');
      });

      socket.on('message', (data) {
        print("Message received: $data");
        _messagesController.add(data);
      });

      socket.onError((error) {
        print("Socket.IO error: $error");
      });

      socket.onDisconnect((_) {
        print("Socket.IO connection closed");
      });
    } catch (e) {
      print('Socket.IO connection error: $e');
    }
  }

  void connectToRoom(String roomCode) {
    socket.emit('join', {'roomCode': roomCode});
    print("Connected to room: $roomCode");
  }

void sendMessage(String roomCode, String message) {
  if (socket.connected) {
    socket.emit('message', {
    'action': 'MESSAGE', 
    'message': message,  
    'roomCode': roomCode, 
  });
  print("Message sent: $message");
  } else {
    print('Socket is not connected.');
  }
}


  @override
  void dispose() {
    socket.dispose();
    _messagesController.close();
    super.dispose();
  }
}
