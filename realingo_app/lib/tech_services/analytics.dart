import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class Analytics {
  static late Mixpanel _mixpanel;

  // following https://developer.mixpanel.com/docs/flutter
  static Future<void> init() async {
    _mixpanel = await Mixpanel.init('bd2013ac83669dc2539fd16abe1464e6', optOutTrackingDefault: false);
    _mixpanel.setServerURL('https://api-eu.mixpanel.com');
    _mixpanel.identify("TODO_NICOLAS"); // TODO NICO ADD IDENTIFIER FOR MIXPANEL
  }

  static void startLesson() {}
}
