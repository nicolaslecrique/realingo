import 'package:flutter/material.dart';
import 'package:realingo_app/model/user_program.dart';

class HomeRouteArgs {
  final UserLearningProgram userProgram;

  HomeRouteArgs(this.userProgram);
}

class HomeRoute extends StatefulWidget {
  static const route = '/home';

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final HomeRouteArgs homeRouteArgs = ModalRoute.of(context).settings.arguments;
    final UserLearningProgram userProgram = homeRouteArgs.userProgram;

    // https://flutter.dev/docs/cookbook/lists/long-lists
    final List<UserItemToLearn> items = userProgram.itemsToLearn;
    return Scaffold(
        body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];
              return ListTile(
                title: Text(item.label),
                tileColor: item.status == UserItemToLearnStatus.KnownAtStart ? Colors.grey : Colors.green,
              );
            }));
  }
}
