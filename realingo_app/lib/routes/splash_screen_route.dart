import 'package:flutter/material.dart';
import 'package:realingo_app/routes/program_route.dart';
import 'package:realingo_app/services/user_program_services.dart';
import 'package:realingo_app/tech_services/db.dart';

import 'login_route.dart';

class SplashScreenRoute extends StatefulWidget {
  static const route = '/splash_screen';

  @override
  _SplashScreenRouteState createState() => _SplashScreenRouteState();
}

class _SplashScreenRouteState extends State<SplashScreenRoute> {
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
      Navigator.pushReplacementNamed(context, LoginRoute.route);
    } else {
      Navigator.pushReplacementNamed(context, ProgramRoute.route,
          arguments: ProgramRouteArgs(db, userProgram));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Splash Screen")),
    );
  }
}
