import 'package:flutter/material.dart';
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
    return StandardScreen(
      title: "Learn this word ?",
      contentChild: Text("todo"),
      bottomChild: Row(
        children: [
          ElevatedButton(
            child: Text("Skip"),
            onPressed: null,
          ),
          ElevatedButton(
            child: Text("learn"),
            onPressed: null,
          )
        ],
      ),
    );
  }
}
