import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  String? _roomCode;
  bool _isLoading = false;

  Future<void> _createRoom() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:3000/api/chat/create-room'); 
    print('Attempting to create room. Backend URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response received. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Room created successfully. Response data: $responseData');
        setState(() {
          _roomCode = responseData['roomCode'];
        });
      } else {
        print('Failed to create room. Server response: ${response.body}');
        _showError('Failed to create room. Please try again.');
      }
    } catch (error) {
      print('Error occurred while creating room: $error');
      _showError('An error occurred. Please check your internet connection.');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _roomCode != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Room Code: $_roomCode',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/chat', arguments: _roomCode);
                        },
                        child: const Text('Go to Workspace'),
                      ),
                    ],
                  )
                : const Center(child: Text('Failed to create room.')),
      ),
    );
  }
}
