import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  _JoinRoomPageState createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController _roomCodeController = TextEditingController();

  Future<void> _joinRoom(BuildContext context) async {
    final roomCode = _roomCodeController.text;

    final isValid = await _validateRoomCode(roomCode);
    if (isValid) {
      Navigator.pushNamed(context, '/chat', arguments: roomCode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Room Code!')),
      );
    }
  }

  Future<bool> _validateRoomCode(String roomCode) async {
    if (roomCode.isEmpty) {
      return false; 
    }

    final url = Uri.parse('http://localhost:3000/api/chat/validate-room');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'roomCode': roomCode}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['valid'] ?? false;
      }
    } catch (error) {
      print('Error validating room code: $error');
    }
    return false; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _roomCodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Room Code',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _joinRoom(context),
              child: const Text('Join Workspace'),
            ),
          ],
        ),
      ),
    );
  }
}
