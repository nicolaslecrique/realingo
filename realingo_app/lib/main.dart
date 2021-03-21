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

void main() {
  // for debug
  // cf. https://flutter.dev/docs/cookbook/persistence/sqlite, needed to access SharedPreference
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.deleteDataAtStartup) {
    UserConfig.clear();
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
