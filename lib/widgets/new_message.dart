import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final messagesController = TextEditingController();
  @override
  void dispose() {
    messagesController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final message = messagesController.text;
    if (message.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    messagesController.clear();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    print(userData);
    await FirebaseFirestore.instance.collection('chat').add({
      'text': message,
      'createdAt': Timestamp.now(),
      'userld': user.uid,
      'username': userData.data()!['username'],
      'image_url': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              controller: messagesController,
              enableSuggestions: true,
              decoration: const InputDecoration(
                label: Text("Type a message here"),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitMessage,
          )
        ],
      ),
    );
  }
}
