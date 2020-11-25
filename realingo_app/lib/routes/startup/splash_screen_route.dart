import 'package:flutter/material.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/routes/home_route.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/tech_services/database/db.dart';

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
    await db.init();
    UserLearningProgram userProgram = await ProgramServices.getDefaultUserProgramOrNull();

    if (userProgram == null) {
      Navigator.pushNamed(context, LoginRoute.route);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (r) => false, arguments: HomeRouteArgs(userProgram));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Splash Screen")),
    );
  }
}
