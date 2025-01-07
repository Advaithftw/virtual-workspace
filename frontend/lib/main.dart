import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'LoginPage.dart';
import 'SignupPage.dart';
import 'chat_screen.dart';
import 'websocket_service.dart';
import 'home_page.dart';
import 'create_room_page.dart';
import 'join_room_page.dart';
import 'error_page.dart';
import 'file_sharing_page.dart'; 
import 'collaborative_editor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WebSocketService("ws://10.0.2.2:3000"),
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const HomePage(),
          '/createRoom': (context) => const CreateRoomPage(),
          '/joinRoom': (context) => const JoinRoomPage(),
          '/chat': (context) {
            final roomCode = ModalRoute.of(context)?.settings.arguments as String? ?? '';
            return ChatScreen(roomCode: roomCode);
          },
          '/fileSharing': (context) {
            final roomCode = ModalRoute.of(context)?.settings.arguments as String? ?? '';
            return FileSharingPage(roomCode: roomCode);
          },
          '/editor': (context) {
            final roomCode = ModalRoute.of(context)?.settings.arguments as String? ?? '';
            return CollaborativeEditorPage(roomCode: roomCode); 
          },
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const ErrorPage());
        },
      ),
    );
  }
}
