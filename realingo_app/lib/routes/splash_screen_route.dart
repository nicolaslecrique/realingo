import 'package:flutter/material.dart';
import 'package:realingo_app/routes/home_route.dart';
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
    await Db.load();
    var userProgramUri = UserProgramServices.getCurrentUserProgramUriOrNull();

    if (userProgramUri == null) {
      Navigator.pushReplacementNamed(context, LoginRoute.route);
    } else {
      Navigator.pushReplacementNamed(context, HomeRoute.route,
          arguments: HomeRouteArgs(userProgramUri));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Splash Screen")),
    );
  }
}
