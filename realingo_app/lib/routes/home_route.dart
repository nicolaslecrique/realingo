import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/model/user_program_model.dart';

import 'lesson/select_word_and_sentences_route.dart';

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
    // for now no need to use consumer, we suppose it cannot change while we are on this route
    var model = Provider.of<UserProgramModel>(context, listen: false);
    UserLearningProgram userProgram = model.program;

    // https://flutter.dev/docs/cookbook/lists/long-lists
    final List<UserItemToLearn> items = userProgram.itemsToLearn;
    return Scaffold(
      body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return ListTile(
              title: Text(item.label),
              tileColor: _getTileColor(item.status),
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

  Color _getTileColor(UserItemToLearnStatus status) {
    switch (status) {
      case UserItemToLearnStatus.SkippedAtStart:
        return Colors.grey;
      case UserItemToLearnStatus.Learned:
        return Colors.green;
      case UserItemToLearnStatus.Skipped:
        return Colors.orangeAccent;
      case UserItemToLearnStatus.NotLearned:
        return Colors.deepOrangeAccent;
    }
  }
}
