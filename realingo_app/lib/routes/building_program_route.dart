import 'package:flutter/material.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/select_level_route.dart';
import 'package:realingo_app/screens/loading_screen.dart';
import 'package:realingo_app/services/program_services.dart';

// Screen to build a new program, so everything is in local when displaying program_route (as if it comes from splash_screen)

class BuildingProgramRouteArgs {
  final Language originLanguage;
  final Language learnedLanguage;

  BuildingProgramRouteArgs(this.originLanguage, this.learnedLanguage);
}

class BuildingProgramRoute extends StatefulWidget {
  static const route = '/building_program';
  final BuildingProgramRouteArgs args;

  BuildingProgramRoute(this.args, {Key key}) : super(key: key);

  @override
  _BuildingProgramRouteState createState() => _BuildingProgramRouteState(this.args);
}

class _BuildingProgramRouteState extends State<BuildingProgramRoute> {
  final BuildingProgramRouteArgs args;

  _BuildingProgramRouteState(this.args);

  @override
  void initState() {
    super.initState();
    Future<LearningProgram> futureProgram =
        ProgramServices.getProgram(this.args.learnedLanguage, this.args.originLanguage);
    futureProgram.then((value) =>
        Navigator.pushReplacementNamed(context, SelectLevelRoute.route, arguments: SelectLevelRouteArgs(value)));
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen();
  }
}
