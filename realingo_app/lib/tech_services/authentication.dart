import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:realingo_app/tech_services/analytics.dart';
import 'package:realingo_app/tech_services/uxcam.dart';
import 'package:wiredash/wiredash.dart';

class Authentication {
  static Future<void> authenticate(BuildContext context) async {
    // 1) init firebase
    await Firebase.initializeApp();

    // 2) init crashlytics
    // NB: for now crashlytics seems not to work well with flutter (obfuscated stack trace)
    // https://github.com/FirebaseExtended/flutterfire/issues/1150
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // 3) authenticate user
    FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential cred = await auth.signInAnonymously();
    String userId = cred.user!.uid;

    // 4) set userId for feedback tool
    Wiredash.of(context)!.setUserProperties(userId: userId);

    if (!kDebugMode) {
      // 4) init tracking
      initUxCam(userId);
      await Analytics.init(userId);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
  }
}
