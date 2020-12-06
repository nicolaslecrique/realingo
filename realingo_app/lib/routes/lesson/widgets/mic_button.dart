import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_states.dart';

class MicButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(
      builder: (BuildContext context, LessonModel lesson, Widget child) {
        LessonState state = lesson.state;
        if (state is WaitForListeningAvailable || state is WaitForAnswerResult) {
          return ElevatedButton.icon(icon: Icon(Icons.mic), label: Text('...'), onPressed: null);
        }
        if (state is WaitForAnswer) {
          return ElevatedButton.icon(icon: Icon(Icons.mic), label: Text('Reply'), onPressed: lesson.startListening);
        }
        if (state is ListeningAnswer) {
          return ElevatedButton.icon(icon: Icon(Icons.mic), label: Text('End'), onPressed: lesson.stopListening);
        }
        throw Exception('MicButton should not be displayed with state $state');
      },
    );
  }
}
