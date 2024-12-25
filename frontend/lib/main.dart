import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'LoginPage.dart';
import 'SignupPage.dart';
import 'chat_screen.dart';
import 'websocket_service.dart';
import 'home_page.dart';
import 'create_room_page.dart';
import 'join_room_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WebSocketService("ws://localhost:3000"),
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const HomePage(),
          '/createRoom': (context) => const CreateRoomPage(),
          '/joinRoom': (context) => const JoinRoomPage(),
          '/chat': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            print("ChatScreen arguments: $args");
            return ChatScreen(roomCode: args as String? ?? '');
          },
        },
      ),
    );
  }
}
