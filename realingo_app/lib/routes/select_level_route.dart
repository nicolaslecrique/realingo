import 'package:flutter/material.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/screens/one_button_screen.dart';
import 'package:realingo_app/services/program_services.dart';

import 'home_route.dart';

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
  ItemToLearn _selectedFirstWordToLearn = null;

  _onItemSelected(ItemToLearn item) {
    setState(() {
      _selectedFirstWordToLearn = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SelectLevelRouteArgs args = ModalRoute.of(context).settings.arguments;
    final List<ItemToLearn> items = args.learningProgram.itemsToLearn;

    return OneButtonScreen(
      title: "Select the first word you don't know",
      child: Expanded(
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index].label),
                tileColor: items[index] == _selectedFirstWordToLearn ? Colors.blue : null,
                onTap: () => _onItemSelected(items[index]),
              );
            }),
      ),
      buttonText: "Ok",
      onButtonPressed: _selectedFirstWordToLearn == null
          ? null
          : () async {
              UserLearningProgram userProgram =
                  await ProgramServices.buildUserProgram(args.learningProgram, _selectedFirstWordToLearn);
              Navigator.pushReplacementNamed(context, HomeRoute.route, arguments: HomeRouteArgs(userProgram));
            },
    );
  }
}
