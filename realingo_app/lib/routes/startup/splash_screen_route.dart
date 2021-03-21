import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/home/home_route.dart';
import 'package:realingo_app/routes/new_program/building_program_route.dart';
import 'package:realingo_app/services/program_services.dart';

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
    await Firebase.initializeApp();
    var model = Provider.of<UserProgramModel>(context, listen: false);
    await model.reload();
    UserLearningProgram userProgram = model.program;

    if (userProgram == null) {
      List<Language> targets = await ProgramServices.getAvailableTargetLanguages();
      List<Language> origins = await ProgramServices.getAvailableOriginLanguages(targets.first);
      await Navigator.pushNamedAndRemoveUntil(context, BuildingProgramRoute.route, (r) => false,
          arguments: BuildingProgramRouteArgs(origins.first, targets.first));
    } else {
      await Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //nb: logo is done with https://cooltext.com/
      body: Padding(
        padding: const EdgeInsets.all(StandardSizes.medium),
        child: Center(child: Image(image: AssetImage('assets/images/logo.png'))),
      ),
    );
  }
}
