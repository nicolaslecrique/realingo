import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:realingo_app/routes/home_route.dart';
import 'package:realingo_app/routes/lesson/select_sentences_for_word_route.dart';
import 'package:realingo_app/routes/lesson/select_word_in_lesson_route.dart';
import 'package:realingo_app/routes/new_program/building_program_route.dart';
import 'package:realingo_app/routes/new_program/select_learned_language_route.dart';
import 'package:realingo_app/routes/new_program/select_level_route.dart';
import 'package:realingo_app/routes/new_program/select_origin_language_route.dart';
import 'package:realingo_app/routes/startup/login_route.dart';
import 'package:realingo_app/routes/startup/splash_screen_route.dart';
import 'package:realingo_app/tech_services/app_config.dart';
import 'package:realingo_app/tech_services/database/db_init.dart';
import 'package:realingo_app/tech_services/user_config.dart';

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
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: SplashScreenRoute.route,
        routes: {
          SplashScreenRoute.route: (context) => SplashScreenRoute(),
          SelectLearnedLanguageRoute.route: (context) => SelectLearnedLanguageRoute(),
          SelectOriginLanguageRoute.route: (context) =>
              // cannot load arguments directly in widget build() because initState needs it
              SelectOriginLanguageRoute(ModalRoute.of(context).settings.arguments),
          HomeRoute.route: (context) => HomeRoute(),
          LoginRoute.route: (context) => LoginRoute(),
          SelectLevelRoute.route: (context) => SelectLevelRoute(),
          SelectWordInLessonRoute.route: (context) => SelectWordInLessonRoute(),
          SelectSentencesForWordRoute.route: (context) => SelectSentencesForWordRoute(),
          BuildingProgramRoute.route: (context) => BuildingProgramRoute(ModalRoute.of(context).settings.arguments),
        });
  }
}
