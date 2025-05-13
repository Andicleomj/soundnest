// ignore_for_file: avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Konfigurasi Firebase untuk Android.
class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = android;

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDywdoot5ID1lXKG1wQPTioxENmgJsJ3pM',
    appId: '1:307643391567:android:02b4ee9aecf759d220943a',
    messagingSenderId: '307643391567',
    projectId: 'databaseta-108d5',
    storageBucket: 'databaseta-108d5.firebasestorage.app',
    databaseURL: 'https://databaseta-108d5-default-rtdb.firebaseio.com',
  );
}
