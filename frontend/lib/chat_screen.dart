import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'websocket_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomCode;
  const ChatScreen({required this.roomCode, super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<WebSocketService>(context, listen: false)
        .connectToRoom(widget.roomCode);
  }

  @override
  Widget build(BuildContext context) {
    final webSocketService = Provider.of<WebSocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room: ${widget.roomCode}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<String>(
              stream: webSocketService.messages.cast<String>(), 
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: [Text(snapshot.data!)],
                  );
                }
                return const Center(child: Text('No messages yet.'));
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Message'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  webSocketService.sendMessage(_controller.text, widget.roomCode);
                  _controller.clear(); 
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
