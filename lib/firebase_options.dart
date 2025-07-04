// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA71qZUCGtZegYkLE1ZQUbCI9Xd3ELNxRw',
    appId: '1:489367389264:web:85f03b6dc5215ae4533d55',
    messagingSenderId: '489367389264',
    projectId: 'asset-tracker-f0c9f',
    authDomain: 'asset-tracker-f0c9f.firebaseapp.com',
    storageBucket: 'asset-tracker-f0c9f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUvQ5cX11205typr7Tm91tt87guarXL7E',
    appId: '1:489367389264:android:a6f37fb2875b5839533d55',
    messagingSenderId: '489367389264',
    projectId: 'asset-tracker-f0c9f',
    storageBucket: 'asset-tracker-f0c9f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVwTc4fPG7IiakoZ2YLz4W3cUJpRTGGmo',
    appId: '1:489367389264:ios:73fbe6f67c4ddb4e533d55',
    messagingSenderId: '489367389264',
    projectId: 'asset-tracker-f0c9f',
    storageBucket: 'asset-tracker-f0c9f.firebasestorage.app',
    iosBundleId: 'com.example.finalProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCVwTc4fPG7IiakoZ2YLz4W3cUJpRTGGmo',
    appId: '1:489367389264:ios:73fbe6f67c4ddb4e533d55',
    messagingSenderId: '489367389264',
    projectId: 'asset-tracker-f0c9f',
    storageBucket: 'asset-tracker-f0c9f.firebasestorage.app',
    iosBundleId: 'com.example.finalProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA71qZUCGtZegYkLE1ZQUbCI9Xd3ELNxRw',
    appId: '1:489367389264:web:3ec5b1838f6ec4c3533d55',
    messagingSenderId: '489367389264',
    projectId: 'asset-tracker-f0c9f',
    authDomain: 'asset-tracker-f0c9f.firebaseapp.com',
    storageBucket: 'asset-tracker-f0c9f.firebasestorage.app',
  );
}
