import 'package:firebase_core/firebase_core.dart';

/// Config copied from google-services.json (Firebase console).
/// These values are not secret — Firebase client keys are meant to be
/// embedded in the app; real security comes from Firestore/Storage rules.
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIMAILiZS6dD7L3YXgl43UmjU3j2tLjCw',
    appId: '1:904667801501:android:e3c83798df1339e8c7f174',
    messagingSenderId: '904667801501',
    projectId: 'diario-app-9b504',
    storageBucket: 'diario-app-9b504.firebasestorage.app',
  );
}
