import 'package:flutter/foundation.dart';

import 'lesson_builder.dart';

enum LessonStatus { WaitForVoiceServiceReady, OnLessonItem, Completed }

@immutable
class LessonState {
  final double ratioCompleted;
  final LessonItemState currentItemOrNull;
  final LessonStatus status;

  const LessonState(this.ratioCompleted, this.currentItemOrNull, this.status);
}

enum LessonItemStatus {
  ReadyForAnswer,
  WaitForListeningAvailable,
  ListeningAnswer,
  WaitForAnswerResult,
  CorrectAnswer,
  CorrectAnswerNoHint
}

@immutable
class LessonItemState {
  final LessonItem lessonItem;
  final Hint hint;
  final AnswerResult lastAnswer;
  final LessonItemStatus status;

  const LessonItemState(this.lessonItem, this.hint, this.lastAnswer, this.status);
}

@immutable
class AnswerResult {
  final String answer;

  const AnswerResult(this.answer);
}

@immutable
class Hint {
  final String hintDisplayed;
  final int nbHintProvided;

  const Hint(this.hintDisplayed, this.nbHintProvided);
}
