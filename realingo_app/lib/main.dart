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
        ProgramRoute.route: (context) => ProgramRoute(),
        LoginRoute.route: (context) => LoginRoute()
      },
      onGenerateRoute: (settings) {
        // this hacks is because SelectOriginLanguageRoute use the parameter
        //in setState, and we cannot get arguments from named routes in setState
        // only in build
        // https://flutter.dev/docs/cookbook/navigation/navigate-with-arguments#alternatively-extract-the-arguments-using-ongenerateroute
        // https://stackoverflow.com/questions/56262655/flutter-get-passed-arguments-from-navigator-in-widgets-states-initstate
        if (settings.name == SelectOriginLanguageRoute.route) {
          final SelectOriginLanguageRouteArgs args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return SelectOriginLanguageRoute(
                  targetLanguage: args.targetLanguage);
            },
          );
        }
        return null;
      },
    );
  }
}
