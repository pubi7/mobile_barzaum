import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin.dart';
import 'user.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isLogin = false;
  final nameCon = TextEditingController();
  final ageCon = TextEditingController();
  final emailCon = TextEditingController();
  final passwordCon = TextEditingController();

  void submit() async {
    final name = nameCon.text.trim();
    final age = ageCon.text.trim();
    final email = emailCon.text.trim();
    final password = passwordCon.text.trim();

    try {
      if (isLogin) {
        final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = userCred.user!.uid; // Get the user ID
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get(); // Fetch user data from Firestore

        final role = doc['role'] ?? 'user'; // Get the role from Firestore

        if (role == 'admin') {
          // Navigate to admin page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminPage()),
          );
        } else {
          // Navigate to user page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => UserPage()),
          );
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login successfully")));
      } else {
        //register
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
              'name': name,
              'age': int.tryParse(age) ?? 0,
              'email': email,
              'role': 'user',
            });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("account created successfully")));
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext contex) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Register")),
      body: ListView(
        children: [
          if (!isLogin) ...[
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: nameCon,
              onChanged: (value) {},
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Age'),
              controller: ageCon,
              onChanged: (value) {},
            ),
          ],
          TextField(
            decoration: InputDecoration(labelText: 'Email'),
            controller: emailCon,
            onChanged: (value) {},
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
            controller: passwordCon,
            onChanged: (value) {},
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isLogin = !isLogin; //false
              });
            },
            child: Text(
              isLogin
                  ? "Dont have account? Register now"
                  : "Already have an account?",
            ),
          ),

          ElevatedButton(
            onPressed: submit,
            child: Text(isLogin ? "Login" : "Register"),
          ),
        ],
      ),
    );
  }
}
