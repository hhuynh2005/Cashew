// File generated for StudyDocs DMS Firebase Integration.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with study_docs_app.
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCqI-n0BvoVElB_8zKtZV4d2WSYE2y9dCQ',
    appId: '1:547153434445:web:cad786a0f50bb21d2f4904',
    messagingSenderId: '547153434445',
    projectId: 'cashew-study-docs',
    authDomain: 'cashew-study-docs.firebaseapp.com',
    storageBucket: 'cashew-study-docs.firebasestorage.app',
    measurementId: 'G-WMR5ZZP8HP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqPn9omYNwxE346aIRoFserVFYH_d9VyM',
    appId: '1:547153434445:android:c66f373a46d8f3c42f4904',
    messagingSenderId: '547153434445',
    projectId: 'cashew-study-docs',
    storageBucket: 'cashew-study-docs.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrp_fvDhLJzztJv6yBpc_IbCinuh69r38',
    appId: '1:547153434445:ios:862b587d838be2022f4904',
    messagingSenderId: '547153434445',
    projectId: 'cashew-study-docs',
    storageBucket: 'cashew-study-docs.firebasestorage.app',
  );
}
