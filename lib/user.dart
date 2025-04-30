import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab9/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';

class UserPage extends StatelessWidget {
  void showEdit(BuildContext context, String uid, String name, String age) {
    final NameCon = TextEditingController(text: name);
    final AgeCon = TextEditingController(text: age);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: NameCon,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: AgeCon,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newName = NameCon.text.trim();
                  final newAge = AgeCon.text.trim();

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                        'name': newName,
                        'age': int.tryParse(newAge) ?? 0,
                      });
                  Navigator.pop(context);
                },
                child: Text('Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('User Page')),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: EdgeInsets.all(10),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${data['name']}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Age: ${data['age']}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Email: ${data['email']}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Role: ${data['role']}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      icon: Icon(Icons.logout),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final name = data['name'] ?? '';
                        final age = data['age']?.toString() ?? '';

                        showEdit(context, currentUser?.uid ?? '', name, age);
                      },
                    ),

                    IconButton(
                      onPressed: () {
                        // Navigate to chat page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => ChatPage()),
                        );
                      },
                      icon: Icon(Icons.chat_bubble),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
