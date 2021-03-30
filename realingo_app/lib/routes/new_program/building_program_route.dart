import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/common_screens/loading_screen.dart';
import 'package:realingo_app/common_screens/recoverable_error.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/home/home_route.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/tech_services/result.dart';

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
  final BuildingProgramRouteArgs? args;

  const BuildingProgramRoute(this.args, {Key? key}) : super(key: key);

  @override
  _BuildingProgramRouteState createState() => _BuildingProgramRouteState();
}

class _BuildingProgramRouteState extends State<BuildingProgramRoute> {
  @override
  void initState() {
    super.initState();
    _buildProgram().then((value) => null);
  }

  bool _errorLoadingProgram = false;

  void setErrorLoadingProgram(bool isError) {
    setState(() {
      _errorLoadingProgram = isError;
    });
  }

  Future<void> _buildProgram() async {
    setErrorLoadingProgram(false);
    Result<LearningProgram> program =
        await ProgramServices.getProgram(widget.args!.learnedLanguage, widget.args!.originLanguage);
    if (program.isOk) {
      await ProgramServices.setDefaultUserProgram(program.result);
      UserProgramModel model = Provider.of<UserProgramModel>(context, listen: false);
      await model.loadDefaultProgram();
      await Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (r) => false);
    } else {
      setErrorLoadingProgram(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorLoadingProgram) {
      return RecoverableError(taskMessage: 'Building program', retryAction: _buildProgram);
    } else {
      return LoadingScreen(message: 'Building program');
    }
  }
}
