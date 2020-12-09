import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_states.dart';

class MicButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(
      builder: (BuildContext context, LessonModel lesson, Widget child) {
        LessonItemState state = lesson.state.currentItemOrNull;
        LessonItemStatus status = state.status;
        if (status == LessonItemStatus.WaitForListeningAvailable || status == LessonItemStatus.WaitForAnswerResult) {
          return ElevatedButton.icon(icon: Icon(Icons.mic), label: Text('...'), onPressed: null);
        }
        if (status == LessonItemStatus.ReadyForAnswer) {
          return ElevatedButton.icon(icon: Icon(Icons.mic), label: Text('Reply'), onPressed: lesson.startListening);
        }
        if (status == LessonItemStatus.ListeningAnswer) {
          return ElevatedButton.icon(
            icon: Icon(Icons.mic),
            label: Text('End'),
            onPressed: lesson.stopListening,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.error),
            ),
          );
        }
        throw Exception('MicButton should not be displayed with state $status');
      },
    );
  }
}
