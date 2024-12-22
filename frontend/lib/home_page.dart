import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createRoom');
              },
              child: const Text('Create Room'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/joinRoom');
              },
              child: const Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }
}
