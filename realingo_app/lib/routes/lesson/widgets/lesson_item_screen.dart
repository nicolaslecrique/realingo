import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_states.dart';
import 'package:realingo_app/routes/lesson/widgets/user_reply.dart';

import 'lesson_progress_bar.dart';
import 'mic_button.dart';

class LessonItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget child) {
      LessonStateOnItem state = lesson.state as LessonStateOnItem;
      debugPrint('lesson state changed to ${lesson.state}');

      return Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(StandardSizes.medium),
              child: Column(
                children: [
                  LessonProgressBar(ratioCompleted: state.ratioCompleted),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
                    child: Text('Translate the sentence'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
                    child: Text(state.lessonItem.sentence.translation),
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      UserReply(),
                    ],
                  )),
                  SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          OutlineButton.icon(
                              icon: Icon(Icons.lightbulb_outline), label: Text('Hint'), onPressed: () => null),
                          SizedBox(width: StandardSizes.medium),
                          Expanded(child: MicButton()),
                        ],
                      )),
                ],
              )));
    });
  }
}
