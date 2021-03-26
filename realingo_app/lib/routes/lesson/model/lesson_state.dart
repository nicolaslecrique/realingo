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
  ConfirmOrCancel,
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
  final WaitingAnswer? AnswerWaitingForConfirmationOrNull; // not null if ExerciseStatus is ConfirmOrCancel
  final AnswerResult? lastAnswerOrNull; // null if not reply given still
  final ExerciseStatus status;
  final bool lastAnswerCanceledOrEmpty;

  const ExerciseState(this.exercise, this.lastAnswerOrNull, this.status,
      {this.AnswerWaitingForConfirmationOrNull, this.lastAnswerCanceledOrEmpty = false});
}

@immutable
class WaitingAnswer {
  final String rawAnswer;
  final String guessedAnswer; // we try to infer what the user wanted to say

  const WaitingAnswer(this.rawAnswer, this.guessedAnswer);
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
