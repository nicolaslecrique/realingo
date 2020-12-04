import 'package:flutter/foundation.dart';

import 'lesson_builder.dart';

@immutable
abstract class LessonState {
  final double ratioCompleted;

  const LessonState(this.ratioCompleted);
}

@immutable
abstract class LessonStateOnItem extends LessonState {
  final LessonItem lessonItem;

  const LessonStateOnItem(double ratioCompleted, this.lessonItem) : super(ratioCompleted);
}

@immutable
class AnswerResult {
  final String answer;

  const AnswerResult(this.answer);
}

@immutable
class WaitForVoiceServiceReady extends LessonState {
  const WaitForVoiceServiceReady(double ratioCompleted) : super(ratioCompleted);
}

@immutable
class WaitForAnswer extends LessonStateOnItem {
  final AnswerResult previousAnswer;

  const WaitForAnswer(double ratioCompleted, LessonItem lessonItem, this.previousAnswer)
      : super(ratioCompleted, lessonItem);
}

@immutable
class WaitForListeningAvailable extends LessonStateOnItem {
  const WaitForListeningAvailable(double ratioCompleted, LessonItem lessonItem) : super(ratioCompleted, lessonItem);
}

@immutable
class ListeningAnswer extends LessonStateOnItem {
  const ListeningAnswer(double ratioCompleted, LessonItem lessonItem) : super(ratioCompleted, lessonItem);
}

// user has given a reply, we wait to know if it's success or not
@immutable
class WaitForAnswerResult extends LessonStateOnItem {
  const WaitForAnswerResult(double ratioCompleted, LessonItem lessonItem) : super(ratioCompleted, lessonItem);
}

@immutable
class CorrectAnswer extends LessonStateOnItem {
  final AnswerResult answer;

  const CorrectAnswer(double ratioCompleted, LessonItem lessonItem, this.answer) : super(ratioCompleted, lessonItem);
}

@immutable
class EndOfLesson extends LessonState {
  const EndOfLesson() : super(1.0);
}
