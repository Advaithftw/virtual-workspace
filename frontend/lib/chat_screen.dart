import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'websocket_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomCode;
  const ChatScreen({required this.roomCode, super.key});

  @override
   createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = []; 

  @override
  void initState() {
    super.initState();
    final webSocketService = Provider.of<WebSocketService>(context, listen: false);

    webSocketService.connectToRoom(widget.roomCode);


    webSocketService.messages.listen((message) {
      setState(() {
        _messages.add(message); 
      });
    });
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
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_messages[index]),
              ),
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
                  final message = _controller.text;
                  webSocketService.sendMessage(message, widget.roomCode);
                  setState(() {
                    _messages.add('You: $message'); 
                  });
                  _controller.clear();
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('File Sharing'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/fileSharing',
                    arguments: widget.roomCode,
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editor'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/editor',
                    arguments: widget.roomCode,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
