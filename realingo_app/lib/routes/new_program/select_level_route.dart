import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/common_screens/loading_screen.dart';
import 'package:realingo_app/common_screens/one_button_screen.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/services/program_services.dart';

import '../home_route.dart';

class SelectLevelRouteArgs {
  final LearningProgram learningProgram;

  SelectLevelRouteArgs(this.learningProgram);
}

class SelectLevelRoute extends StatefulWidget {
  static const route = '/select_level';

  const SelectLevelRoute({Key key}) : super(key: key);

  @override
  _SelectLevelRouteState createState() => _SelectLevelRouteState();
}

class _SelectLevelRouteState extends State<SelectLevelRoute> {
  ItemToLearn _selectedFirstWordToLearn;
  bool _savingProgram = false;

  void _onItemSelected(ItemToLearn item) {
    setState(() {
      _selectedFirstWordToLearn = item;
    });
  }

  Future<void> _onOk(LearningProgram learningProgram) async {
    setState(() {
      _savingProgram = true;
    });

    await ProgramServices.buildUserProgram(learningProgram, _selectedFirstWordToLearn);

    var model = Provider.of<UserProgramModel>(context, listen: false);
    await model.reload();
    await Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_savingProgram) {
      return LoadingScreen();
    }

    final args = ModalRoute.of(context).settings.arguments as SelectLevelRouteArgs;
    final items = args.learningProgram.itemsToLearn;

    return OneButtonScreen(
      title: "Select the first word you don't know",
      child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index].label),
              selected: items[index] == _selectedFirstWordToLearn,
              onTap: () => _onItemSelected(items[index]),
            );
          }),
      buttonText: 'Ok',
      onButtonPressed: _selectedFirstWordToLearn == null ? null : () async => _onOk(args.learningProgram),
    );
  }
}
