import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_states.dart';

class UserReply extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(
      builder: (BuildContext context, LessonModel lesson, Widget child) {
        LessonState state = lesson.state;

        String answer;
        if (state is WaitForAnswer) {
          answer = state.previousAnswer?.answer ?? '';
        } else if (state is CorrectAnswer) {
          answer = state.answer.answer;
        } else {
          answer = '';
        }

        return Text(answer);
      },
    );
  }
}
