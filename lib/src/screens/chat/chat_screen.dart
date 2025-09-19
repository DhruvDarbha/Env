import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/chat_interface.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreshTrack AI Assistant'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: ChatInterface(),
      ),
    );
  }
}