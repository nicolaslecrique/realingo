import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:realingo_app/routes/login_route.dart';
import 'package:realingo_app/routes/program_route.dart';
import 'package:realingo_app/routes/select_origin_language_route.dart';
import 'package:realingo_app/routes/select_target_language_route.dart';
import 'package:realingo_app/routes/splash_screen_route.dart';

void main() {
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
        SelectTargetLanguageRoute.route: (context) =>
            SelectTargetLanguageRoute(),
        SelectOriginLanguageRoute.route: (context) =>
            SelectOriginLanguageRoute(),
        ProgramRoute.route: (context) => ProgramRoute(),
        LoginRoute.route: (context) => LoginRoute()
      },
    );
  }
}
