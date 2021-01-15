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
  CorrectAnswerCorrectPronunciation,
  CorrectAnswerBadPronunciation,
  BadAnswer
}

@immutable
class LessonItemState {
  final LessonItem lessonItem;
  final AnswerResult lastAnswerOrNull; // null if not reply given still
  final LessonItemStatus status;

  const LessonItemState(this.lessonItem, this.lastAnswerOrNull, this.status);
}

@immutable
class AnswerResult {
  final String rawAnswer;
  final List<AnswerPart> processedAnswer;

  const AnswerResult(this.rawAnswer, this.processedAnswer);
}

@immutable
class AnswerPart {
  final String expectedWord;
  final bool isPronunciationCorrect;

  const AnswerPart(this.expectedWord, this.isPronunciationCorrect);
}
