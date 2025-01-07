import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> createRoom(BuildContext context) async {
    final roomCode = "room_${DateTime.now().millisecondsSinceEpoch}";
    final url = Uri.parse('http://10.0.2.2:3000/api/createRoom');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'roomCode': roomCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Room created: ${data['room']}');
        Navigator.pushNamed(context, '/chatRoom', arguments: roomCode);
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'Failed to create room')),
        );
      }
    } catch (e) {
      print('Error creating room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create room')),
      );
    }
  }

  Future<void> joinRoom(BuildContext context) async {
    final TextEditingController roomCodeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Join Room'),
          content: TextField(
            controller: roomCodeController,
            decoration: const InputDecoration(hintText: 'Enter Room Code'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final roomCode = roomCodeController.text.trim();
                if (roomCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room code cannot be empty')),
                  );
                  return;
                }

                final url = Uri.parse('http://<YOUR_BACKEND_URL>/api/joinRoom/$roomCode');

                try {
                  final response = await http.get(url);

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/chatRoom', arguments: roomCode);
                  } else {
                    final error = jsonDecode(response.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error['error'] ?? 'Room not found')),
                    );
                  }
                } catch (e) {
                  print('Error joining room: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to join room')),
                  );
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: FutureBuilder<String?>(
        future: getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final token = snapshot.data;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (token != null) ...[
                  Text(
                    'Welcome! Your token is: $token',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                ],
                ElevatedButton(
                  onPressed: () {
                    createRoom(context);
                  },
                  child: const Text('Create Room'),
                ),
                ElevatedButton(
                  onPressed: () {
                    joinRoom(context);
                  },
                  child: const Text('Join Room'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
