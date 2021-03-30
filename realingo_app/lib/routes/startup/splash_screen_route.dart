import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/common_screens/recoverable_error.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/home/home_route.dart';
import 'package:realingo_app/routes/new_program/building_program_route.dart';
import 'package:realingo_app/services/program_services.dart';

@immutable
class SplashScreenRoute extends StatefulWidget {
  static const route = '/splash_screen';

  const SplashScreenRoute({Key? key}) : super(key: key);

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

  bool _errorLoadingProgram = false;

  void setErrorLoadingProgram(bool isError) {
    setState(() {
      _errorLoadingProgram = isError;
    });
  }

  Future<void> loadUserDataThenRedirect() async {
    setErrorLoadingProgram(false);
    var model = Provider.of<UserProgramModel>(context, listen: false);
    await model.loadDefaultProgram();
    switch (model.status) {
      case UserProgramModelStatus.NoDefaultProgram:
        var resultTarget = await ProgramServices.getAvailableTargetLanguages();
        if (!resultTarget.isOk) {
          setErrorLoadingProgram(true);
          return;
        }
        List<Language> targets = (resultTarget).result;
        var resultOrigin = await ProgramServices.getAvailableOriginLanguages(targets.first);
        if (!resultOrigin.isOk) {
          setErrorLoadingProgram(true);
          return;
        }

        List<Language> origins = (resultOrigin).result;
        await Navigator.pushNamedAndRemoveUntil(context, BuildingProgramRoute.route, (r) => false,
            arguments: BuildingProgramRouteArgs(origins.first, targets.first));
        break;
      case UserProgramModelStatus.LoadingFailed:
        setState(() {
          setErrorLoadingProgram(true);
        });
        return;
      case UserProgramModelStatus.Loaded:
        await Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (r) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorLoadingProgram) {
      return RecoverableError(taskMessage: 'Loading program', retryAction: loadUserDataThenRedirect);
    } else {
      return Scaffold(
        //nb: logo is done with https://cooltext.com/
        body: Padding(
          padding: const EdgeInsets.all(StandardSizes.medium),
          child: Center(child: Image(image: AssetImage('assets/images/logo.png'))),
        ),
      );
    }
  }
}
