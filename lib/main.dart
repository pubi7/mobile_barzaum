import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'admin.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AuthGate());
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseAuth.instance
              .authStateChanges(), //check if user is logged in or not

      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final uid = snapshot.data!.uid; // Get the user ID
          return FutureBuilder(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get(), // Fetch user data from Firestore
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final role = snapshot.data!.get(
                'role',
              ); // Get the role from Firestore
              if (role == 'admin') {
                return AdminPage(); // Navigate to admin page
              } else {
                return UserPage(); // Navigate to user page
              }
            },
          );
        } else {
          return LoginPage(); // Show login page if not logged in
        }
      },
    );
  }
}






//CRUD - Create, Read, Update, Delete