import 'package:flutter/material.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/screens/loading_screen.dart';
import 'package:realingo_app/screens/one_button_screen.dart';
import 'package:realingo_app/services/program_services.dart';

import '../home_route.dart';

class SelectLevelRouteArgs {
  final LearningProgram learningProgram;

  SelectLevelRouteArgs(this.learningProgram);
}

class SelectLevelRoute extends StatefulWidget {
  static const route = '/select_level';

  @override
  _SelectLevelRouteState createState() => _SelectLevelRouteState();
}

class _SelectLevelRouteState extends State<SelectLevelRoute> {
  ItemToLearn _selectedFirstWordToLearn;
  bool _savingProgram = false;

  _onItemSelected(ItemToLearn item) {
    setState(() {
      _selectedFirstWordToLearn = item;
    });
  }

  void _onOk(LearningProgram learningProgram) async {
    setState(() {
      _savingProgram = true;
    });

    UserLearningProgram userProgram =
        await ProgramServices.buildUserProgram(learningProgram, _selectedFirstWordToLearn);
    Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (r) => false, arguments: HomeRouteArgs(userProgram));
  }

  @override
  Widget build(BuildContext context) {
    if (_savingProgram) {
      return LoadingScreen();
    }

    final SelectLevelRouteArgs args = ModalRoute.of(context).settings.arguments;
    final List<ItemToLearn> items = args.learningProgram.itemsToLearn;

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
      buttonText: "Ok",
      onButtonPressed: _selectedFirstWordToLearn == null ? null : () async => _onOk(args.learningProgram),
    );
  }
}
