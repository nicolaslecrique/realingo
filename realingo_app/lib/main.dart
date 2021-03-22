import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/home/home_route.dart';
import 'package:realingo_app/routes/lesson/lesson_route.dart';
import 'package:realingo_app/routes/new_program/building_program_route.dart';
import 'package:realingo_app/routes/startup/splash_screen_route.dart';
import 'package:realingo_app/tech_services/app_config.dart';
import 'package:realingo_app/tech_services/user_config.dart';

import 'design/constants.dart';

Future<void> main() async {
  // for debug
  // cf. https://flutter.dev/docs/cookbook/persistence/sqlite, needed to access SharedPreference
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
  // NB: for now crashlytics seems not to work well with flutter (obfuscated stack trace)
  // https://github.com/FirebaseExtended/flutterfire/issues/1150
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  if (AppConfig.deleteDataAtStartup) {
    await UserConfig.clear();
  }

  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProgramModel())],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: StandardColors.themeColor,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            accentColor: StandardColors.accentColor,
          ),
          initialRoute: SplashScreenRoute.route,
          routes: {
            SplashScreenRoute.route: (BuildContext context) => const SplashScreenRoute(),
            HomeRoute.route: (BuildContext context) => const HomeRoute(),
            LessonRoute.route: (BuildContext context) => const LessonRoute(),
            BuildingProgramRoute.route: (BuildContext context) =>
                BuildingProgramRoute(ModalRoute.of(context).settings.arguments as BuildingProgramRouteArgs),
          }),
    );
  }
}
