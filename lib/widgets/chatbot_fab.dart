import 'package:flutter/material.dart';
import '../screens/ai/ai_chat_screen.dart';

class ChatbotFAB extends StatelessWidget {
  const ChatbotFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIChatScreen()),
        );
      },
      backgroundColor: Colors.white,
      child: Image.asset('assets/chatbot.png', width: 32, height: 32),
    );
  }
}
