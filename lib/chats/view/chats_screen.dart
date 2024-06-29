import 'package:flutter/material.dart';

import '../../utils/appcolors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolor.themeColor,
        title: const Text('Chats'),
      ),
      body: const Center(
        child: Text('Chats'),
      ),
    );
  }
}
