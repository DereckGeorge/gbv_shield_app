import 'package:flutter/material.dart';

class ChatbotFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  const ChatbotFAB({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () {},
      backgroundColor: Colors.white,
      child: Image.asset('assets/chatbot.png', width: 32, height: 32),
    );
  }
}
