import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';

class ReplyRichText extends StatelessWidget {
  final ExerciseState exerciseState;

  const ReplyRichText({Key? key, required this.exerciseState}) : super(key: key);

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    return RichText(text: _getTextSpan(context, exerciseState));
  }

  TextSpan _getTextSpan(BuildContext context, ExerciseState exerciseState) {
    var defaultTextStyle = Theme.of(context).textTheme.headline5!;
    var badPronunciationTextStyle = defaultTextStyle.apply(color: StandardColors.accentColor);
    var goodTextStyle = defaultTextStyle.apply(color: StandardColors.correct);
    var errorTextStyle = defaultTextStyle.apply(color: StandardColors.incorrect);

    if (exerciseState.lastAnswerOrNull == null) {
      switch (exerciseState.exercise.exerciseType) {
        case ExerciseType.TranslateToLearningLanguage:
          return TextSpan(text: exerciseState.exercise.sentence.hint, style: defaultTextStyle);
        case ExerciseType.Repeat:
          return TextSpan(text: exerciseState.exercise.sentence.sentence, style: defaultTextStyle);
      }
    } else {
      switch (exerciseState.lastAnswerOrNull!.answerStatus) {
        case AnswerStatus.CorrectAnswerCorrectPronunciation:
          return TextSpan(text: exerciseState.exercise.sentence.sentence, style: goodTextStyle);
        case AnswerStatus.CorrectAnswerBadPronunciation:
        case AnswerStatus.CorrectAnswerBadPronunciationNoMoreTry:
          return TextSpan(
              children: exerciseState.lastAnswerOrNull!.processedAnswer
                  .map((AnswerPart e) => TextSpan(
                      text: e.expectedWord,
                      style: e.isPronunciationCorrect ? goodTextStyle : badPronunciationTextStyle))
                  .toList());
        case AnswerStatus.BadAnswer:
          return TextSpan(text: exerciseState.exercise.sentence.sentence, style: errorTextStyle);
      }
    }
  }
}
