import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/program.dart';

enum LessonStatus { WaitForVoiceServiceReady, OnLessonItem, Completed }

@immutable
class LessonState {
  final double ratioCompleted;
  final LessonItemState? currentItemOrNull;
  final LessonStatus status;

  const LessonState(this.ratioCompleted, this.currentItemOrNull, this.status);
}

enum LessonItemStatus {
  ReadyForFirstAnswer,
  WaitForListeningAvailable,
  ListeningAnswer,
  WaitForAnswerResult,
  OnAnswerFeedback
}

enum AnswerStatus {
  CorrectAnswerCorrectPronunciation,
  CorrectAnswerBadPronunciation,
  CorrectAnswerBadPronunciationNoMoreTry,
  BadAnswer
}

@immutable
class LessonItemState {
  final Sentence sentence;
  final AnswerResult? lastAnswerOrNull; // null if not reply given still
  final LessonItemStatus status;

  const LessonItemState(this.sentence, this.lastAnswerOrNull, this.status);
}

@immutable
class AnswerResult {
  final String rawAnswer;
  final List<AnswerPart> processedAnswer;
  final AnswerStatus answerStatus;
  final int? remainingTryIfBadPronunciationOrNull;

  const AnswerResult(
      this.rawAnswer, this.processedAnswer, this.answerStatus, this.remainingTryIfBadPronunciationOrNull);
}

@immutable
class AnswerPart {
  final String expectedWord;
  final bool isPronunciationCorrect;

  const AnswerPart(this.expectedWord, this.isPronunciationCorrect);
}
