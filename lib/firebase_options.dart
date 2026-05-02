import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC71yR8sCfzVeIJocRX8oN30DK56IclgLg',
    appId: '1:413995246042:android:06132243a72be3c92220e3',
    messagingSenderId: '413995246042',
    projectId: 'doctor-parrilla-clientes',
    storageBucket: 'doctor-parrilla-clientes.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKuQxhLHIFW5kJur_FDTRwuhp2GnchQ7E',
    appId: '1:413995246042:ios:3f7ef87dc71093b42220e3',
    messagingSenderId: '413995246042',
    projectId: 'doctor-parrilla-clientes',
    storageBucket: 'doctor-parrilla-clientes.firebasestorage.app',
    iosBundleId: 'com.drparrilla.app',
  );
}
