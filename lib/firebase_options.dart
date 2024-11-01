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
    apiKey: 'AIzaSyBaY3PD5Nh_cSJVROwUP9KDvcAd_B1wZzE',
    appId: '1:141606097790:web:ca045419724d1cca6d192f',
    messagingSenderId: '141606097790',
    projectId: 'yummy-database',
    authDomain: 'yummy-database.firebaseapp.com',
    storageBucket: 'yummy-database.appspot.com',
    measurementId: 'G-BT28FZDZP0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBj9GCDJlU9QCK8rgIWCHHR50FeIz9_VMU',
    appId: '1:141606097790:android:f24d69b05639853f6d192f',
    messagingSenderId: '141606097790',
    projectId: 'yummy-database',
    storageBucket: 'yummy-database.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdyLk8mzTIuEXGTHLFZnv3_fpIySzzzvk',
    appId: '1:141606097790:ios:587d1e20a3f67dab6d192f',
    messagingSenderId: '141606097790',
    projectId: 'yummy-database',
    storageBucket: 'yummy-database.appspot.com',
    iosClientId: '141606097790-k8jc3rm0tjl9s9likcccotp9ubh5hgop.apps.googleusercontent.com',
    iosBundleId: 'com.example.demoYummy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdyLk8mzTIuEXGTHLFZnv3_fpIySzzzvk',
    appId: '1:141606097790:ios:587d1e20a3f67dab6d192f',
    messagingSenderId: '141606097790',
    projectId: 'yummy-database',
    storageBucket: 'yummy-database.appspot.com',
    iosClientId: '141606097790-k8jc3rm0tjl9s9likcccotp9ubh5hgop.apps.googleusercontent.com',
    iosBundleId: 'com.example.demoYummy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBaY3PD5Nh_cSJVROwUP9KDvcAd_B1wZzE',
    appId: '1:141606097790:web:6e287edaad00e25c6d192f',
    messagingSenderId: '141606097790',
    projectId: 'yummy-database',
    authDomain: 'yummy-database.firebaseapp.com',
    storageBucket: 'yummy-database.appspot.com',
    measurementId: 'G-ZHHG618M2W',
  );
}