import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';

class _State {
  final String buttonText;
  final IconData buttonIcon;
  final Color buttonColorOrNull;
  final VoidCallback Function(LessonModel lesson) buttonAction;
  final Color backgroundColorOrNull;
  final Color textColorOrNull;
  final String titleText;
  final String Function(LessonItemState item) subtitleTextOrNull;

  _State(this.buttonText, this.buttonIcon, this.buttonColorOrNull, this.buttonAction,
      {this.backgroundColorOrNull, this.textColorOrNull, this.titleText = '', this.subtitleTextOrNull});

  static final _State ready = _State('Reply', Icons.mic, null, (LessonModel lesson) => lesson.startListening);
  static final _State wait = _State('...', Icons.mic, StandardColors.brandBlue, (LessonModel lesson) => (() => null));
  static final _State listen = _State('...', Icons.mic, null, (LessonModel lesson) => lesson.stopListening);

  static final _State badPronunciation = _State('Retry', Icons.mic, null, (LessonModel lesson) => lesson.startListening,
      backgroundColorOrNull: Colors.grey,
      textColorOrNull: StandardColors.correct,
      titleText: 'Good!',
      subtitleTextOrNull: (LessonItemState item) => 'Listen and try to improve your pronunciation');

  static final _State perfect = _State(
      'Continue', Icons.check, StandardColors.correct, (LessonModel lesson) => lesson.nextLessonItem,
      backgroundColorOrNull: Colors.grey,
      textColorOrNull: StandardColors.correct,
      titleText: 'Perfect!',
      subtitleTextOrNull: (LessonItemState item) => 'Keep going, you are the best!');

  static final _State bad = _State(
      'Continue', Icons.arrow_forward_ios, StandardColors.incorrect, (LessonModel lesson) => lesson.nextLessonItem,
      backgroundColorOrNull: Colors.grey,
      textColorOrNull: StandardColors.incorrect,
      titleText: 'Your reply:',
      subtitleTextOrNull: (LessonItemState item) => item.lastAnswerOrNull.rawAnswer);

  static _State getState(LessonItemStatus status) {
    switch (status) {
      case LessonItemStatus.ReadyForAnswer:
        return ready;
      case LessonItemStatus.WaitForListeningAvailable:
        return wait;
      case LessonItemStatus.ListeningAnswer:
        return listen;
      case LessonItemStatus.WaitForAnswerResult:
        return wait;
      case LessonItemStatus.CorrectAnswerCorrectPronunciation:
        return perfect;
      case LessonItemStatus.CorrectAnswerBadPronunciation:
        return badPronunciation;
      case LessonItemStatus.BadAnswer:
        return bad;
    }
  }
}

class LessonItemBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget child) {
      var status = lesson.state.currentItemOrNull.status;

      _State state = _State.getState(status);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(state.titleText,
              style: Theme.of(context).textTheme.subtitle1.apply(color: state.textColorOrNull, fontWeightDelta: 3)),
          Text(
              // maxLine and '\n' trick to always keep same size
              state.subtitleTextOrNull == null ? '\n' : state.subtitleTextOrNull(lesson.state.currentItemOrNull) + '\n',
              maxLines: 2,
              style: Theme.of(context).textTheme.subtitle1.apply(color: state.textColorOrNull)),
          ElevatedButton.icon(
              style:
                  state.buttonColorOrNull == null ? null : ElevatedButton.styleFrom(primary: state.buttonColorOrNull),
              onPressed: state.buttonAction(lesson),
              icon: Icon(state.buttonIcon),
              label: Text(state.buttonText))
        ],
      );
    });
  }
}
