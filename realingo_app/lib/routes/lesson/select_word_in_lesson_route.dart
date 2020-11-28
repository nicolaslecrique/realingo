import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/routes/lesson/select_sentences_for_word_route.dart';
import 'package:realingo_app/screens/standard_screen.dart';
import 'package:realingo_app/services/lesson_services.dart';

class SelectWordInLessonRouteArgs {
  final UserLearningProgram userLearningProgram;
  final List<ConsideredItem> itemsForLesson;

  SelectWordInLessonRouteArgs(this.userLearningProgram, this.itemsForLesson);
}

class SelectWordInLessonRoute extends StatefulWidget {
  static const route = '/select_word_in_lesson';

  @override
  _SelectWordInLessonRouteState createState() => _SelectWordInLessonRouteState();
}

class _SelectWordInLessonRouteState extends State<SelectWordInLessonRoute> {
  int _currentIndex;
  SelectWordInLessonRouteArgs _args;

  void _onChoice(ItemSkippedOrSelected choice) {
    List<ConsideredItem> newList =
        List.unmodifiable(List.from(_args.itemsForLesson)..add(ConsideredItem(_currentIndex, choice, null)));
    if (choice == ItemSkippedOrSelected.Selected) {
      Navigator.pushNamed(context, SelectSentencesForWordRoute.route,
          arguments: SelectSentencesForWordRouteArgs(_args.userLearningProgram, newList));
    } else {
      if (_currentIndex == _args.itemsForLesson.length - 1) {
        // TODO NICO: start lesson
      } else {
        Navigator.pushNamed(context, SelectWordInLessonRoute.route,
            arguments: SelectWordInLessonRouteArgs(_args.userLearningProgram, newList));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _args = ModalRoute.of(context).settings.arguments;
    final program = _args.userLearningProgram;

    if (_args.itemsForLesson.isEmpty) {
      _currentIndex =
          program.itemsToLearn.indexWhere((UserItemToLearn e) => e.status == UserItemToLearnStatus.NotLearned);
    } else {
      _currentIndex = _args.itemsForLesson.last.indexInUserProgram + 1;
    }
    UserItemToLearn itemToLearn = program.itemsToLearn[_currentIndex];

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
              onPressed: () => _onChoice(ItemSkippedOrSelected.Skipped),
            ),
          ),
          SizedBox(width: StandardSizes.medium),
          Expanded(
            child: ElevatedButton(
              child: Text("learn"),
              onPressed: () => _onChoice(ItemSkippedOrSelected.Selected),
            ),
          )
        ],
      ),
    );
  }
}
