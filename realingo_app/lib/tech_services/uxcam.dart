// @dart=2.9
//ux_cam not yet null safe but it doesn't matter
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_uxcam/flutter_uxcam.dart';

void initUxCam(String userId) {
  FlutterUxcam.optInOverall();
  FlutterUxcam.startWithKey('8yhqvisgpswtm7s');
  FlutterUxcam.setUserIdentity(userId);
}
