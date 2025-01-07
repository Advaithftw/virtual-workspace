import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart'; 

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  bool _isLoading = false;

  Future<void> _createRoom() async {
    setState(() {
      _isLoading = true;
    });

    const url = 'http://10.0.2.2:3000/api/chat/create-room';
    const roomName = 'New Room'; 

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'roomName': roomName}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final roomCode = data['room']['name']; 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(roomCode: roomCode),
          ),
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        _showError('Failed to create room: $error');
      }
    } catch (err) {
      _showError('An error occurred: $err');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    _createRoom(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Redirecting to the chat room...'),
      ),
    );
  }
}
