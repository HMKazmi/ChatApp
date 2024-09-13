import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text(
              'Error occured while loading chats.',
            ),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No chats found',
            ),
          );
        }
        final loadedMessages = chatSnapshot.data!.docs;
        return Container(
          child: ListView.builder(
              // padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: chatSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final chatMessage = loadedMessages[index].data();
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;
                final currentMessageUserId = chatMessage['userld'];
                final nextMessageUserId = nextChatMessage != null
                    ? nextChatMessage['userld']
                    : null;

                final nextUserIsSame =
                    currentMessageUserId == nextMessageUserId;
                if (nextUserIsSame) {

                  return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  ); 
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['image_url'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid ==
                          currentMessageUserId); 
                  ////////
                  // if (index < chatSnapshot.data!.docs.length) {
                  //   return ListTile(
                  //     title: Text(chatSnapshot.data!.docs[index]['text']),
                  //     subtitle: Text(chatSnapshot.data!.docs[index]['username']),
                  //   );
                  // }
                }
              }),
        );
      },
    );
  }
}
