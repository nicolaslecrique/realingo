import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';

class ReplyRichText extends StatelessWidget {
  final LessonItemState itemState;

  const ReplyRichText({Key key, this.itemState}) : super(key: key);

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    var defaultTextStyle = Theme.of(context).textTheme.headline5;
    var errorTextStyle = defaultTextStyle.apply(color: StandardColors.accentColor);
    if (itemState.lastAnswerOrNull == null) {
      return RichText(text: TextSpan(text: itemState.sentence.hint, style: defaultTextStyle));
    }

    switch (itemState.lastAnswerOrNull.answerStatus) {
      case AnswerStatus.CorrectAnswerCorrectPronunciation:
        return RichText(text: TextSpan(text: itemState.sentence.sentence, style: defaultTextStyle));
      case AnswerStatus.CorrectAnswerBadPronunciation:
      case AnswerStatus.CorrectAnswerBadPronunciationNoMoreTry:
        return RichText(
            text: TextSpan(
                children: itemState.lastAnswerOrNull.processedAnswer
                    .map((AnswerPart e) => TextSpan(
                        text: e.expectedWord, style: e.isPronunciationCorrect ? defaultTextStyle : errorTextStyle))
                    .toList()));
      case AnswerStatus.BadAnswer:
        return RichText(text: TextSpan(text: itemState.sentence.sentence, style: defaultTextStyle));
    }
  }
}
