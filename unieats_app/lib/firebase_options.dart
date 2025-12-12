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
    apiKey: 'AIzaSyC5kjWFzBNUzHxXjpjuGqLBkoIKR9z6P5s',
    appId: '1:1044017820994:web:121e0283906840f20184db',
    messagingSenderId: '1044017820994',
    projectId: 'unieats-f88f7',
    authDomain: 'unieats-f88f7.firebaseapp.com',
    storageBucket: 'unieats-f88f7.firebasestorage.app',
    measurementId: 'G-X5G9X6HY4H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDPtWHT0jzzR3gcPQ2ydlDIIWNJP1BJfmc',
    appId: '1:1044017820994:android:63e9431612f240630184db',
    messagingSenderId: '1044017820994',
    projectId: 'unieats-f88f7',
    storageBucket: 'unieats-f88f7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC9HP5-MqO0eopgGrABafquxn1i1Ms3cMI',
    appId: '1:1044017820994:ios:2742322a065c61f90184db',
    messagingSenderId: '1044017820994',
    projectId: 'unieats-f88f7',
    storageBucket: 'unieats-f88f7.firebasestorage.app',
    iosBundleId: 'com.example.unieatsApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC9HP5-MqO0eopgGrABafquxn1i1Ms3cMI',
    appId: '1:1044017820994:ios:2742322a065c61f90184db',
    messagingSenderId: '1044017820994',
    projectId: 'unieats-f88f7',
    storageBucket: 'unieats-f88f7.firebasestorage.app',
    iosBundleId: 'com.example.unieatsApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC5kjWFzBNUzHxXjpjuGqLBkoIKR9z6P5s',
    appId: '1:1044017820994:web:696b7fd4591f78e30184db',
    messagingSenderId: '1044017820994',
    projectId: 'unieats-f88f7',
    authDomain: 'unieats-f88f7.firebaseapp.com',
    storageBucket: 'unieats-f88f7.firebasestorage.app',
    measurementId: 'G-M6L9TYXRV4',
  );
}
