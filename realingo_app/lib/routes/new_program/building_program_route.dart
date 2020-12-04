import 'package:flutter/material.dart';
import 'package:realingo_app/common_screens/loading_screen.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/new_program/select_level_route.dart';
import 'package:realingo_app/services/program_services.dart';

// Screen to build a new program, so everything is in local when displaying program_route (as if it comes from splash_screen)

@immutable
class BuildingProgramRouteArgs {
  final Language originLanguage;
  final Language learnedLanguage;

  const BuildingProgramRouteArgs(this.originLanguage, this.learnedLanguage);
}

@immutable
class BuildingProgramRoute extends StatefulWidget {
  static const route = '/building_program';
  final BuildingProgramRouteArgs args;

  const BuildingProgramRoute(this.args, {Key key}) : super(key: key);

  @override
  _BuildingProgramRouteState createState() => _BuildingProgramRouteState();
}

class _BuildingProgramRouteState extends State<BuildingProgramRoute> {
  @override
  void initState() {
    super.initState();

    Future<LearningProgram> futureProgram =
        ProgramServices.getProgram(widget.args.learnedLanguage, widget.args.originLanguage);
    futureProgram
        .then((value) => Navigator.pushNamed(context, SelectLevelRoute.route, arguments: SelectLevelRouteArgs(value)));
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen();
  }
}
