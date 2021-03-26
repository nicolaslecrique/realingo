import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';

class _State {
  final String buttonText;
  final IconData buttonIcon;
  final Color? buttonColorOrNull;
  final VoidCallback Function(LessonModel lesson) buttonAction;
  final Color? backgroundColorOrNull;
  final Color? textColorOrNull;
  final String titleText;
  final String Function(ExerciseState item)? subtitleTextOrNull;
  final bool displayCancelReplyButton;

  _State(this.buttonText, this.buttonIcon, this.buttonColorOrNull, this.buttonAction,
      {this.backgroundColorOrNull,
      this.textColorOrNull,
      this.titleText = '',
      this.subtitleTextOrNull,
      this.displayCancelReplyButton = false});

  static final _State ready = _State('Reply', Icons.mic, null, (LessonModel lesson) => lesson.startListening);
  static final _State wait =
      _State('...', Icons.mic, StandardColors.brandBlue, (LessonModel lesson) => lesson.stopListening);
  static final _State listen =
      _State('End', Icons.mic, StandardColors.accentColor, (LessonModel lesson) => lesson.stopListening);

  static final _State badPronunciation = _State('Retry', Icons.mic, null, (LessonModel lesson) => lesson.startListening,
      backgroundColorOrNull: Colors.grey,
      textColorOrNull: StandardColors.correct,
      titleText: 'Good!',
      subtitleTextOrNull: (ExerciseState item) =>
          "Listen and try to improve your pronunciation (${item.lastAnswerOrNull!.remainingTryIfBadPronunciationOrNull} more ${item.lastAnswerOrNull!.remainingTryIfBadPronunciationOrNull == 1 ? 'try' : 'tries'})");

  static final _State badPronunciationNoTry = _State(
      'Continue', Icons.check, StandardColors.correct, (LessonModel lesson) => lesson.nextLessonItem,
      backgroundColorOrNull: Colors.grey,
      textColorOrNull: StandardColors.correct,
      titleText: 'Good!',
      subtitleTextOrNull: (ExerciseState item) => "No more try, you'll do better next time");

  static final _State perfect = _State(
      'Continue', Icons.check, StandardColors.correct, (LessonModel lesson) => lesson.nextLessonItem,
      backgroundColorOrNull: Colors.grey,
      textColorOrNull: StandardColors.correct,
      titleText: 'Perfect!',
      subtitleTextOrNull: (ExerciseState item) => 'Keep going, you are the best!');

  static final _State bad = _State(
      'Continue', Icons.arrow_forward_ios, StandardColors.incorrect, (LessonModel lesson) => lesson.nextLessonItem,
      backgroundColorOrNull: Colors.grey,
      textColorOrNull: StandardColors.incorrect,
      titleText: 'Wrong answer, your reply:',
      subtitleTextOrNull: (ExerciseState item) => item.lastAnswerOrNull!.rawAnswer);

  static final _State _confirmOrCancel = _State(
      'Confirm', Icons.check, StandardColors.brandBlue, (lesson) => lesson.confirmAnswer,
      displayCancelReplyButton: true,
      titleText: 'Your reply:',
      subtitleTextOrNull: (ExerciseState item) => item.AnswerWaitingForConfirmationOrNull!.guessedAnswer);

  // ignore: missing_return
  static _State getState(ExerciseStatus status, AnswerStatus? answerStatusOrNull) {
    switch (status) {
      case ExerciseStatus.ReadyForFirstAnswer:
        return ready;
      case ExerciseStatus.WaitForListeningAvailable:
        return wait;
      case ExerciseStatus.ListeningAnswer:
        return listen;
      case ExerciseStatus.WaitForAnswerResult:
        return wait;
      case ExerciseStatus.ConfirmOrCancel:
        return _confirmOrCancel;
      case ExerciseStatus.OnAnswerFeedback:
        AnswerStatus answerStatus = answerStatusOrNull!;
        switch (answerStatus) {
          case AnswerStatus.CorrectAnswerCorrectPronunciation:
            return perfect;
          case AnswerStatus.CorrectAnswerBadPronunciation:
            return badPronunciation;
          case AnswerStatus.CorrectAnswerBadPronunciationNoMoreTry:
            return badPronunciationNoTry;
          case AnswerStatus.BadAnswer:
            return bad;
        }
    }
  }
}

class LessonItemBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget? child) {
      var status = lesson.state.currentExerciseOrNull!.status;

      _State state = _State.getState(status, lesson.state.currentExerciseOrNull!.lastAnswerOrNull?.answerStatus);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(state.titleText,
              style: Theme.of(context).textTheme.subtitle1!.apply(color: state.textColorOrNull, fontWeightDelta: 3)),
          Text(
              // maxLine and '\n' trick to always keep same size
              state.subtitleTextOrNull == null
                  ? '\n'
                  : state.subtitleTextOrNull!(lesson.state.currentExerciseOrNull!) + '\n',
              maxLines: 2,
              style: Theme.of(context).textTheme.subtitle1!.apply(color: state.textColorOrNull)),
          Row(
            children: state.displayCancelReplyButton
                ? [
                    Expanded(
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(primary: StandardColors.accentColor),
                          onPressed: lesson.cancelAnswer,
                          icon: Icon(Icons.close),
                          label: Text('Retry')),
                    ),
                    SizedBox(width: StandardSizes.medium),
                    buildMainButton(state, lesson),
                  ]
                : [buildMainButton(state, lesson)],
          )
        ],
      );
    });
  }

  Widget buildMainButton(_State state, LessonModel lesson) {
    return Expanded(
      child: ElevatedButton.icon(
          style: state.buttonColorOrNull == null ? null : ElevatedButton.styleFrom(primary: state.buttonColorOrNull),
          onPressed: state.buttonAction(lesson),
          icon: Icon(state.buttonIcon),
          label: Text(state.buttonText)),
    );
  }
}
