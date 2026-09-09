import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/firebase_options.dart';

/// Boots Firebase when [DefaultFirebaseOptions.isConfigured] is true.
///
/// Optional emulator (dev):
/// `--dart-define=USE_FIRESTORE_EMULATOR=true`
/// then `firebase emulators:start --only firestore --project demo-newlane`
class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static bool _ready = false;

  static bool get isReady => _ready;

  static const bool useEmulator = bool.fromEnvironment(
    'USE_FIRESTORE_EMULATOR',
    defaultValue: false,
  );

  static Future<void> init() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      AppLog.line(
        '[FIREBASE] skipped — GoogleService-Info / firebase_options missing',
      );
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (useEmulator) {
        const String host = kIsWeb ? 'localhost' : '10.0.2.2';
        FirebaseFirestore.instance.useFirestoreEmulator(
          defaultTargetPlatform == TargetPlatform.android ? host : 'localhost',
          8080,
        );
        AppLog.line('[FIREBASE] Firestore emulator @ :8080');
      }

      _ready = true;
      AppLog.line('[FIREBASE] ready');
    } catch (error, stack) {
      AppLog.section('FIREBASE INIT FAILED', <String, Object?>{
        'ERROR': error,
        'STACK': stack,
      });
      _ready = false;
    }
  }
}
