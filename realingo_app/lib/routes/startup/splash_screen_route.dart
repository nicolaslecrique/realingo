import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/home_route.dart';
import 'package:realingo_app/routes/new_program/select_learned_language_route.dart';
import 'package:realingo_app/tech_services/database/db.dart';

@immutable
class SplashScreenRoute extends StatefulWidget {
  static const route = '/splash_screen';

  const SplashScreenRoute({Key key}) : super(key: key);

  @override
  _SplashScreenRouteState createState() => _SplashScreenRouteState();
}

class _SplashScreenRouteState extends State<SplashScreenRoute> {
  @override
  void initState() {
    super.initState();
    // https://pub.dev/documentation/provider/latest/provider/Provider/of.html
    loadUserDataThenRedirect().then((value) => null);
  }

  Future<void> loadUserDataThenRedirect() async {
    await db.init();
    var model = Provider.of<UserProgramModel>(context, listen: false);
    await model.reload();
    UserLearningProgram userProgram = model.program;

    if (userProgram == null) {
      await Navigator.pushNamedAndRemoveUntil(context, SelectLearnedLanguageRoute.route, (r) => false);
    } else {
      await Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Splash Screen')),
    );
  }
}
