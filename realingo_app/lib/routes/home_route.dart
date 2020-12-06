import 'package:flutter/material.dart';
import 'package:realingo_app/model/user_program.dart';

import 'lesson/select_word_and_sentences_route.dart';

@immutable
class HomeRouteArgs {
  final UserLearningProgram userProgram;

  const HomeRouteArgs(this.userProgram);
}

class HomeRoute extends StatefulWidget {
  static const route = '/home';

  const HomeRoute({Key key}) : super(key: key);

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
    final HomeRouteArgs homeRouteArgs = ModalRoute.of(context).settings.arguments as HomeRouteArgs;
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
              tileColor: item.status == UserItemToLearnStatus.SkippedAtStart ? Colors.grey : Colors.green,
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, SelectWordAndSentencesRoute.route,
            arguments: SelectWordAndSentencesRouteArgs(userProgram, const [])),
        label: Text('Start lesson'),
        icon: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
