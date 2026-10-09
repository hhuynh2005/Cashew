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
    apiKey: 'AIzaSyCxPNAB6WxjGxAySTlubG09THKMOiwIZKY',
    appId: '1:825188339992:web:64ee99e1f75034613a0e6d',
    messagingSenderId: '825188339992',
    projectId: 'cashew-study-docs-d5b15',
    authDomain: 'cashew-study-docs-d5b15.firebaseapp.com',
    storageBucket: 'cashew-study-docs-d5b15.firebasestorage.app',
    measurementId: 'G-MFFDG761WJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCyNMrtBDC24tM03NwYcrXr2PMjSlr91do',
    appId: '1:825188339992:android:e6605e14dd2778a83a0e6d',
    messagingSenderId: '825188339992',
    projectId: 'cashew-study-docs-d5b15',
    storageBucket: 'cashew-study-docs-d5b15.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrp_fvDhLJzztJv6yBpc_IbCinuh69r38',
    appId: '1:547153434445:ios:862b587d838be2022f4904',
    messagingSenderId: '547153434445',
    projectId: 'cashew-study-docs',
    storageBucket: 'cashew-study-docs.firebasestorage.app',
  );
}
