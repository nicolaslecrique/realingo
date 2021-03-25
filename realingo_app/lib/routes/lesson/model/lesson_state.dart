import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/program.dart';

enum LessonStatus { WaitForVoiceServiceReady, OnLessonItem, Completed }

@immutable
class LessonState {
  final double ratioCompleted;
  final ExerciseState? currentExerciseOrNull;
  final LessonStatus status;

  const LessonState(this.ratioCompleted, this.currentExerciseOrNull, this.status);
}

enum ExerciseStatus {
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
class ExerciseState {
  final Exercise exercise;
  final AnswerResult? lastAnswerOrNull; // null if not reply given still
  final ExerciseStatus status;

  const ExerciseState(this.exercise, this.lastAnswerOrNull, this.status);
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
