import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_states.dart';

import 'mic_button.dart';

class LessonItemBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget child) {
      var status = lesson.state.currentItemOrNull.status;
      if (status == LessonItemStatus.CorrectAnswer || status == LessonItemStatus.CorrectAnswerNoHint) {
        return SizedBox(
            width: double.infinity,
            child: IconButton(onPressed: lesson.nextLessonItem, icon: Icon(Icons.check), tooltip: 'Next'));
      } else {
        return Row(
          children: [
            IconButton(icon: Icon(Icons.lightbulb_outline), onPressed: lesson.askForHint, tooltip: 'Hint'),
            SizedBox(width: StandardSizes.medium),
            Expanded(child: MicButton())
          ],
        );
      }
    });
  }
}
