import 'package:flutter/material.dart';
import 'package:realingo_app/screens/program_screen.dart';
import 'package:realingo_app/screens/select_target_language_screen.dart';
import 'package:realingo_app/services/user_program_services.dart';
import 'package:realingo_app/tech_services/db.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    loadUserDataThenRedirect().then((value) => null);
  }

  Future<void> loadUserDataThenRedirect() async {
    Db db = await DbLoader.load();
    UserProgramServices userProgramServices = UserProgramServices(db);
    var userProgram = userProgramServices.getCurrentUserProgramOrNull();

    if (userProgram == null) {
      Navigator.pushReplacementNamed(
          context, SelectTargetLanguageScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, ProgramScreen.routeName,
          arguments: ProgramScreenArgs(db, userProgram));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Splash Screen")),
    );
  }
}
