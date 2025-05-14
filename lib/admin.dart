import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab9/login_page.dart';
import 'create_test_page.dart';

//note to self
//add custom admin claims later
//use nodejs to create admin claims later
class AdminPage extends StatelessWidget {
  void deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  void updateUser(
    String uid,
    String name,
    String age,
    String role,
    String phoneNumber,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name,
      'age': int.tryParse(age) ?? 0,
      'role': role,
      'phone_number': phoneNumber,
    });
  }

  addUser(
    String name,
    String age,
    String email,
    String role,
    String password,
    String phoneNumber,
  ) async {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'name': name,
          'age': int.tryParse(age) ?? 0,
          'email': email,
          'role': role,
          'phone_number': phoneNumber,
        });
  }

  void showEdit(
    BuildContext context,
    String uid,
    String name,
    String age,
    String role,
    String phoneNumber,
  ) {
    final nameCon = TextEditingController(text: name);
    final ageCon = TextEditingController(text: age);
    final roleCon = TextEditingController(text: role);
    final phoneCon = TextEditingController(text: phoneNumber);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCon,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: ageCon,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: roleCon,
                  decoration: InputDecoration(labelText: 'Role'),
                ),
                TextField(
                  controller: phoneCon,
                  decoration: InputDecoration(labelText: 'Phone Number'),
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
                  final newName = nameCon.text.trim();
                  final newAge = ageCon.text.trim();
                  final newRole = roleCon.text.trim();
                  final newPhone = phoneCon.text.trim();

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                        'name': newName,
                        'age': int.tryParse(newAge) ?? 0,
                        'role': newRole,
                        'phone_number': newPhone,
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
                  'Email: ${data['email']} \nRole: ${data['role']} \nPhone: ${data['phone_number'] ?? ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Age: ${data['age']}'),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        final name = data['name'] ?? '';
                        final age = data['age'].toString();
                        final role = data['role'] ?? '';
                        final phone = data['phone_number'] ?? '';
                        showEdit(context, user.id, name, age, role, phone);
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
          // Navigate to CreateTestPage
          FloatingActionButton(
            heroTag: 'createTest',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateTestPage()),
              );
            },
            child: Icon(Icons.add_box),
            tooltip: 'Create / Edit Test',
          ),

          SizedBox(width: 16),

          // Add User Button
          FloatingActionButton(
            heroTag: 'addUser',
            onPressed:
                () => showDialog(
                  context: context,
                  builder: (context) {
                    final nameController = TextEditingController();
                    final ageController = TextEditingController();
                    final emailController = TextEditingController();
                    final roleController = TextEditingController();
                    final passwordController = TextEditingController();
                    final phoneController = TextEditingController();

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
                            TextField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                              ),
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
                            final phoneNumber = phoneController.text.trim();

                            if (name.isNotEmpty &&
                                age.isNotEmpty &&
                                email.isNotEmpty &&
                                role.isNotEmpty &&
                                password.isNotEmpty &&
                                phoneNumber.isNotEmpty) {
                              try {
                                await addUser(
                                  name,
                                  age,
                                  email,
                                  role,
                                  password,
                                  phoneNumber,
                                );
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
            child: Icon(Icons.person_add),
            tooltip: 'Add User',
          ),

          SizedBox(width: 16),

          // Logout Button
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}
