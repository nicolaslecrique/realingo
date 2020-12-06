import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';

class LessonProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(
      builder: (BuildContext context, LessonModel lesson, Widget child) => LinearProgressIndicator(
        value: lesson.state.ratioCompleted,
      ),
    );
  }
}
