// File generated manually for Firebase initialization

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDs1fKxzR4gBE2bTgnf7DLuK_GfY8gZu_k",
    authDomain: "myapp-4d681.firebaseapp.com",
    projectId: "myapp-4d681",
    storageBucket: "myapp-4d681.firebasestorage.app",
    messagingSenderId: "592326972994",
    appId: "1:592326972994:web:ad762a6e59ec1a92797fdb",
  );
}


  //  apiKey: "AIzaSyBfCE6IJ5H6vizTxASla4KA-27sVCPVNik",
  //  authDomain: "rababa-80396.firebaseapp.com",
  //  projectId: "rababa-80396",
   // storageBucket: "rababa-80396.firebasestorage.app",
  //  messagingSenderId: "520438730154",
 //   appId: "1:520438730154:web:7588cc619fc9e5e6aaefd3",
  //  measurementId: "G-1601P3DETY",