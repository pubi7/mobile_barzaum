import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  final TextEditingController messageCon =
      TextEditingController(); //get user s msg from text field

  void sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    final userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
    await FirebaseFirestore.instance.collection('chat').add({
      'text': messageCon.text.trim(),
      'senderUid': user.uid,
      'senderName': userData['name'],
      'timestamp': Timestamp.now(),
    });
    messageCon.clear(); //clear the text field after sending msg
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 206, 206),
      appBar: AppBar(title: Text('Chat')),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('chat')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No chats available'));
                }

                final message = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: message.length,
                  itemBuilder: (context, index) {
                    final msg = message[index];
                    return ListTile(
                      title: Text(msg['text']),
                      subtitle: Text(
                        msg['senderName'],
                        style: TextStyle(color: Colors.blue),
                      ),
                      trailing: Text(
                        msg['timestamp'].toDate().toString().substring(0, 16),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: messageCon,
                  ),
                ),
                IconButton(onPressed: sendMessage, icon: Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
