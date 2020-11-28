import 'dart:math';

import 'package:flutter/material.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/routes/lesson/lesson_route.dart';
import 'package:realingo_app/routes/lesson/select_word_in_lesson_route.dart';
import 'package:realingo_app/screens/one_button_screen.dart';

import 'lesson_controller.dart';

class SelectSentencesForWordRouteArgs {
  final UserLearningProgram userLearningProgram;
  final List<ConsideredItem> itemsForLesson;

  SelectSentencesForWordRouteArgs(this.userLearningProgram, this.itemsForLesson);
}

class SelectSentencesForWordRoute extends StatefulWidget {
  static const route = '/select_sentences_for_word';

  @override
  _SelectSentencesForWordRouteState createState() => _SelectSentencesForWordRouteState();
}

class _SelectSentencesForWordRouteState extends State<SelectSentencesForWordRoute> {
  SelectSentencesForWordRouteArgs _args;
  int nbSentencesToLearn;

  List<int> indexSelectedSentences = [];

  void _onValidate() {
    // next word on start lesson
    ConsideredItem itemWithoutSentence = _args.itemsForLesson.last;
    ConsideredItem itemWithSentences = ConsideredItem(
        itemWithoutSentence.indexInUserProgram, itemWithoutSentence.choice, List.unmodifiable(indexSelectedSentences));
    List<ConsideredItem> newItemsList = List.unmodifiable(List.from(_args.itemsForLesson)
      ..removeLast()
      ..add(itemWithSentences));

    if (newItemsList.length == LessonController.NbItemsByLesson) {
      // start lesson

      List<LessonItem> lessonItems = LessonController.buildLesson(_args.userLearningProgram, newItemsList);
      LessonRouteArgs lessonRouteArgs = LessonRouteArgs(lessonItems);
      Navigator.pushNamed(context, LessonRoute.route, arguments: lessonRouteArgs);
    } else {
      SelectWordInLessonRouteArgs newArgs = SelectWordInLessonRouteArgs(_args.userLearningProgram, newItemsList);
      Navigator.pushNamed(context, SelectWordInLessonRoute.route, arguments: newArgs);
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
    _args = ModalRoute.of(context).settings.arguments;
    ConsideredItem consideredItem = _args.itemsForLesson.last;

    UserItemToLearn itemToLearn = _args.userLearningProgram.itemsToLearn[consideredItem.indexInUserProgram];
    nbSentencesToLearn = min(itemToLearn.sentences.length, LessonController.NbSentencesByLessonItem);

    return OneButtonScreen(
        title: "Choose 3 sentences to learn",
        child: Column(
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
                  selected: indexSelectedSentences.contains(index),
                  onTap: () => _onSentenceSelected(index),
                ),
              ),
            )
          ],
        ),
        buttonText: "OK",
        onButtonPressed: indexSelectedSentences.length < nbSentencesToLearn ? null : _onValidate);
  }
}
