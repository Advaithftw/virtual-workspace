import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class CollaborativeEditorPage extends StatefulWidget {
  final String roomCode;

  const CollaborativeEditorPage({required this.roomCode, super.key});

  @override
  State<CollaborativeEditorPage> createState() =>
      _CollaborativeEditorPageState();
}

class _CollaborativeEditorPageState extends State<CollaborativeEditorPage> {
  final TextEditingController _textController = TextEditingController();
  late WebSocketChannel _channel;
  bool _loading = true;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    const wsUrl = 'ws://10.0.2.2:3000/ws'; 
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    
    _channel.stream.listen(
      (message) {
        if (message == 'joined-room:${widget.roomCode}') {
          setState(() {
            _connected = true;
            _loading = false;
          });
        } else {
          _updateTextController(message);
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _reconnectWebSocket();
      },
      onDone: () {
        print('WebSocket closed');
        _reconnectWebSocket();
      },
    );
    _channel.sink.add('join-document:${widget.roomCode}');
  }

  void _reconnectWebSocket() {
    setState(() {
      _connected = false;
      _loading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      _connectWebSocket();
    });
  }

  void _sendTextUpdate(String text) {
    if (_connected) {
      _channel.sink.add('edit-document:${widget.roomCode}:$text');
    }
  }

  void _updateTextController(String newText) {
    final currentText = _textController.text;
    final currentSelection = _textController.selection;

    if (newText != currentText) {
      setState(() {
        _textController.text = newText;
        final offset = currentSelection.baseOffset;
        _textController.selection = TextSelection.collapsed(
          offset: offset <= newText.length ? offset : newText.length,
        );
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collaborative Editor: ${widget.roomCode}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      onChanged: _sendTextUpdate,
                      decoration: const InputDecoration(
                        hintText: 'Start typing...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
