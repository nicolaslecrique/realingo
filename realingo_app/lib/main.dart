import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/home/home_route.dart';
import 'package:realingo_app/routes/lesson/lesson_route.dart';
import 'package:realingo_app/routes/lesson/select_word_and_sentences_route.dart';
import 'package:realingo_app/routes/new_program/building_program_route.dart';
import 'package:realingo_app/routes/new_program/select_learned_language_route.dart';
import 'package:realingo_app/routes/new_program/select_level_route.dart';
import 'package:realingo_app/routes/new_program/select_origin_language_route.dart';
import 'package:realingo_app/routes/startup/splash_screen_route.dart';
import 'package:realingo_app/tech_services/app_config.dart';
import 'package:realingo_app/tech_services/database/db_init.dart';
import 'package:realingo_app/tech_services/user_config.dart';

import 'design/constants.dart';

void main() {
  if (AppConfig.deleteDataAtStartup) {
    // for debug
    deleteDb();
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
            primaryColor: StandardColors.brandBlue,
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: SplashScreenRoute.route,
          routes: {
            SplashScreenRoute.route: (BuildContext context) => const SplashScreenRoute(),
            SelectLearnedLanguageRoute.route: (BuildContext context) => const SelectLearnedLanguageRoute(),
            SelectOriginLanguageRoute.route: (BuildContext context) =>
                // cannot load arguments directly in widget build() because initState needs it
                SelectOriginLanguageRoute(ModalRoute.of(context).settings.arguments as SelectOriginLanguageRouteArgs),
            HomeRoute.route: (BuildContext context) => const HomeRoute(),
            SelectLevelRoute.route: (BuildContext context) => const SelectLevelRoute(),
            LessonRoute.route: (BuildContext context) => const LessonRoute(),
            SelectWordAndSentencesRoute.route: (BuildContext context) => const SelectWordAndSentencesRoute(),
            BuildingProgramRoute.route: (BuildContext context) =>
                BuildingProgramRoute(ModalRoute.of(context).settings.arguments as BuildingProgramRouteArgs),
          }),
    );
  }
}
