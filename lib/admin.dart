import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab9/login_page.dart';

class AdminPage extends StatelessWidget {
  void deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  void updateUser(String uid, String name, String age) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name,
      'age': age,
    });
  }

  addUser(
    String name,
    String age,
    String email,
    String role,
    String password,
  ) async {
    // Register the user in Firebase Authentication
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // Add the user's details to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'name': name,
          'age': int.tryParse(age) ?? 0,
          'email': email,
          'role': role,
        });
  }

  void showEdit(
    BuildContext context,
    String uid,
    String name,
    String age,
    String role,
  ) {
    final NameCon = TextEditingController(text: name);
    final AgeCon = TextEditingController(text: age);
    final RoleCon = TextEditingController(text: role);
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

                TextField(
                  controller: RoleCon,
                  decoration: InputDecoration(labelText: 'Role'),
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
                  final newRole = RoleCon.text.trim();

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                        'name': newName,
                        'age': int.tryParse(newAge) ?? 0,
                        'role': newRole,
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
    return Scaffold(
      appBar: AppBar(title: Text('Admin Page')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final user = docs[index];
              final data = user.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(
                  'Email: ${data['email']} \nRole: ${data['role']}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Age: ${data['age']}'),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        final name = data['name'] ?? '';
                        final age = data['age'].toString() ?? '';
                        final email = data['email'] ?? '';
                        final role = data['role'] ?? '';

                        showEdit(context, user.id, name, age, role);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteUser(user.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed:
                () => showDialog(
                  context: context,
                  builder: (context) {
                    final nameController = TextEditingController();
                    final ageController = TextEditingController();
                    final emailController = TextEditingController();
                    final roleController = TextEditingController();
                    final passwordController = TextEditingController();

                    return AlertDialog(
                      title: Text('Add New User'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(labelText: 'Name'),
                            ),
                            TextField(
                              controller: ageController,
                              decoration: InputDecoration(labelText: 'Age'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(labelText: 'Email'),
                            ),
                            TextField(
                              controller: roleController,
                              decoration: InputDecoration(labelText: 'Role'),
                            ),
                            TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final age = ageController.text.trim();
                            final email = emailController.text.trim();
                            final role = roleController.text.trim();
                            final password = passwordController.text.trim();

                            if (name.isNotEmpty &&
                                age.isNotEmpty &&
                                email.isNotEmpty &&
                                role.isNotEmpty &&
                                password.isNotEmpty) {
                              try {
                                await addUser(name, age, email, role, password);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('User added successfully'),
                                  ),
                                );
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                ),
            child: Icon(Icons.add),
          ),

          SizedBox(width: 16),

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
        ],
      ),
    );
  }
}
