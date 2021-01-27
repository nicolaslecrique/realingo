import 'dart:math';

import 'package:flutter/material.dart';
import 'package:realingo_app/common_screens/standard_screen.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';

import 'lesson_route.dart';

@immutable
class SelectWordAndSentencesRouteArgs {
  final UserLearningProgram userLearningProgram;
  final List<ConsideredItem> itemsForLesson;

  const SelectWordAndSentencesRouteArgs(this.userLearningProgram, this.itemsForLesson);
}

class SelectWordAndSentencesRoute extends StatefulWidget {
  static const route = '/select_word_and_sentences';

  const SelectWordAndSentencesRoute({Key key}) : super(key: key);

  @override
  _SelectWordAndSentencesRouteState createState() => _SelectWordAndSentencesRouteState();
}

class _SelectWordAndSentencesRouteState extends State<SelectWordAndSentencesRoute> {
  int _currentIndex;
  SelectWordAndSentencesRouteArgs _args;
  int nbSentencesToLearn;
  List<int> indexSelectedSentences = [];

  void _onItemSelected() {
    ConsideredItem itemWithSentences =
        ConsideredItem(_currentIndex, ItemSkippedOrSelected.Selected, List.unmodifiable(indexSelectedSentences));
    List<ConsideredItem> newItemsList =
        List.unmodifiable(List<ConsideredItem>.from(_args.itemsForLesson)..add(itemWithSentences));

    if (newItemsList.length == LessonBuilder.NbItemsByLesson || _currentIndex == _args.itemsForLesson.length - 1) {
      // start lesson
      List<LessonItem> lessonItems = LessonBuilder.buildLesson(_args.userLearningProgram, newItemsList);
      LessonRouteArgs lessonRouteArgs = LessonRouteArgs(_args.userLearningProgram.learnedLanguage, lessonItems);
      Navigator.pushNamed(context, LessonRoute.route, arguments: lessonRouteArgs);
    } else {
      SelectWordAndSentencesRouteArgs newArgs =
          SelectWordAndSentencesRouteArgs(_args.userLearningProgram, newItemsList);
      Navigator.pushNamed(context, SelectWordAndSentencesRoute.route, arguments: newArgs);
    }
  }

  void _onSentenceSelected(int index) {
    setState(() {
      if (indexSelectedSentences.contains(index)) {
        indexSelectedSentences.remove(index);
      } else if (indexSelectedSentences.length < nbSentencesToLearn) {
        indexSelectedSentences.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _args = ModalRoute.of(context).settings.arguments as SelectWordAndSentencesRouteArgs;
    final program = _args.userLearningProgram;

    if (_args.itemsForLesson.isEmpty) {
      _currentIndex =
          program.itemsToLearn.indexWhere((UserItemToLearn e) => e.status == UserItemToLearnStatus.NotLearned);
    } else {
      _currentIndex = _args.itemsForLesson.last.indexInUserProgram + 1;
    }
    UserItemToLearn itemToLearn = program.itemsToLearn[_currentIndex];
    nbSentencesToLearn = min(itemToLearn.sentences.length, LessonBuilder.NbSentencesByLessonItem);

    return StandardScreen(
      titleOrNull: 'Select ${LessonBuilder.NbSentencesByLessonItem} sentences',
      contentChild: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(itemToLearn.label),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemToLearn.sentences.length,
              itemBuilder: (BuildContext context, int index) => Card(
                child: ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(itemToLearn.sentences[index].sentence),
                  subtitle: Text(itemToLearn.sentences[index].translation),
                  selected: indexSelectedSentences.contains(index),
                  onTap: () => _onSentenceSelected(index),
                ),
              ),
            ),
          )
        ],
      ),
      bottomChild: ElevatedButton(
        child: Text('Learn'),
        onPressed: indexSelectedSentences.length < nbSentencesToLearn ? null : _onItemSelected,
      ),
    );
  }
}
