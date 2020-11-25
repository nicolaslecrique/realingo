import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/screens/standard_screen.dart';

class SelectWordInLessonRouteArgs {
  final UserLearningProgram userLearningProgram;
  final List<int> selectedItemIdxForLesson;

  SelectWordInLessonRouteArgs(this.userLearningProgram, this.selectedItemIdxForLesson);
}

class SelectWordInLessonRoute extends StatefulWidget {
  static const route = '/select_word_in_lesson';

  @override
  _SelectWordInLessonRouteState createState() => _SelectWordInLessonRouteState();
}

class _SelectWordInLessonRouteState extends State<SelectWordInLessonRoute> {
  @override
  Widget build(BuildContext context) {
    final SelectWordInLessonRouteArgs args = ModalRoute.of(context).settings.arguments;
    final List<UserItemToLearn> items = args.userLearningProgram.itemsToLearn;
    UserItemToLearn itemToLearn = items.firstWhere((UserItemToLearn e) => e.status == UserItemToLearnStatus.NotLearned);

    return StandardScreen(
      title: "Learn this word ?",
      contentChild: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(itemToLearn.label),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemToLearn.sentences.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(itemToLearn.sentences[index].sentence),
                subtitle: Text(itemToLearn.sentences[index].translation),
              ),
            ),
          )
        ],
      ),
      bottomChild: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              child: Text("Skip"),
              onPressed: null,
            ),
          ),
          SizedBox(width: StandardSizes.medium),
          Expanded(
            child: ElevatedButton(
              child: Text("learn"),
              onPressed: null,
            ),
          )
        ],
      ),
    );
  }
}
