import 'package:chat_app/widgets/messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset : false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
        title: Text(
          'FlutterChat',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ), 
      body: const Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Messages(),
                ],
              ),
            ),
          ),
          NewMessage(), // This widget will stay at the bottom of the screen
        ],
      ),
    ); // Center
  }
}
// Scaffold