// Firebase options for New Lane (iOS primary).
// Sourced from GoogleService-Info.plist — project newlane-57145.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  /// iOS is the shipping platform — configured when iOS keys are real.
  static bool get isConfigured {
    final FirebaseOptions opts = ios;
    return opts.apiKey.isNotEmpty &&
        opts.appId.isNotEmpty &&
        opts.projectId.isNotEmpty &&
        opts.messagingSenderId.isNotEmpty &&
        !opts.apiKey.startsWith('REPLACE');
  }

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw UnsupportedError(
        'Firebase is not configured. Add GoogleService-Info.plist values.',
      );
    }
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android app not registered — reuse iOS project metadata for local
        // analysis only. Ship / run on iOS.
        return ios;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBjmsd5h6s8EZ72Xqibx6Wy9-XDJbbsGjk',
    appId: '1:26670736260:ios:2c49d36e2f3463d7a333d1',
    messagingSenderId: '26670736260',
    projectId: 'newlane-57145',
    storageBucket: 'newlane-57145.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjmsd5h6s8EZ72Xqibx6Wy9-XDJbbsGjk',
    appId: '1:26670736260:ios:2c49d36e2f3463d7a333d1',
    messagingSenderId: '26670736260',
    projectId: 'newlane-57145',
    storageBucket: 'newlane-57145.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjmsd5h6s8EZ72Xqibx6Wy9-XDJbbsGjk',
    appId: '1:26670736260:ios:2c49d36e2f3463d7a333d1',
    messagingSenderId: '26670736260',
    projectId: 'newlane-57145',
    storageBucket: 'newlane-57145.firebasestorage.app',
    iosBundleId: 'com.marsbluellc.newlane',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBjmsd5h6s8EZ72Xqibx6Wy9-XDJbbsGjk',
    appId: '1:26670736260:ios:2c49d36e2f3463d7a333d1',
    messagingSenderId: '26670736260',
    projectId: 'newlane-57145',
    storageBucket: 'newlane-57145.firebasestorage.app',
    iosBundleId: 'com.marsbluellc.newlane',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBjmsd5h6s8EZ72Xqibx6Wy9-XDJbbsGjk',
    appId: '1:26670736260:ios:2c49d36e2f3463d7a333d1',
    messagingSenderId: '26670736260',
    projectId: 'newlane-57145',
    storageBucket: 'newlane-57145.firebasestorage.app',
  );
}
