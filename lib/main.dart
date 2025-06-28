import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const ChatAssistantApp());
}

class ChatAssistantApp extends StatelessWidget {
  const ChatAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ollama Chat Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: const ChatScreen(),
    );
  }
}
