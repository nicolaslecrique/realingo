import 'package:flutter/material.dart';
import 'package:realingo_app/screens/program_screen.dart';
import 'package:realingo_app/screens/select_target_language_screen.dart';
import 'package:realingo_app/screens/splash_screen.dart';

void main() {
  runApp(MyApp());
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
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => SplashScreen(),
        SelectTargetLanguageScreen.routeName: (context) =>
            SelectTargetLanguageScreen(),
        ProgramScreen.routeName: (context) => ProgramScreen(),
      },
    );
  }
}
