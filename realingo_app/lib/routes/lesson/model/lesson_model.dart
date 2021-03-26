import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/services/voice_service.dart';

import 'lesson_state.dart';

enum _AnswerQuality { Good, GoodResultBadPronunciation, Bad }

class LessonModel extends ChangeNotifier {
  // immutable fields
  final String learnedLanguageUri;
  final Lesson lesson;
  static final Levenshtein _distance = Levenshtein();
  static const double _maxDistance = 0.5;
  static const int _nbTryForPronunciation = 1;
  final VoiceService _voiceService;
  // https://stackoverflow.com/questions/15531928/matching-unicode-letters-with-regexp
  static final RegExp _normalizeStrRegex = RegExp(r'[^\p{L}]+', unicode: true);
  static final RegExp _whiteSpaceRegex = RegExp(r'[ ]+');

  // internal current state
  LessonState _state;
  final Queue<Exercise> _remainingExercises;
  bool actionInProcess = false; // init, start, stop and nextItem should not happens at the same time

  // getters on current state
  Exercise? get _currentExerciseOrNull => _remainingExercises.isEmpty ? null : _remainingExercises.first;
  LessonState get state => _state;
  double get ratioCompleted =>
      (lesson.exercises.length - _remainingExercises.length).toDouble() / lesson.exercises.length;

  LessonModel(this.learnedLanguageUri, this.lesson)
      : _state = LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady),
        _remainingExercises = QueueList<Exercise>.from(lesson.exercises),
        _voiceService = VoiceService.get() {
    _init();
  }

  void _updateState(LessonState state) {
    _state = state;
    notifyListeners();
  }

  bool _takeLock() {
    if (actionInProcess) {
      return false;
    } else {
      actionInProcess = true;
      return true;
    }
  }

  void _releaseLock() {
    actionInProcess = false;
  }

  Future<void> _init() async {
    if (!_takeLock()) {
      return;
    }

    _updateState(LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady));
    bool initOk = await _voiceService.init();
    if (initOk) {
      _updateState(LessonState(
          ratioCompleted,
          ExerciseState(_currentExerciseOrNull!, null, ExerciseStatus.ReadyForFirstAnswer, null),
          LessonStatus.OnLessonItem));
    } else {
      throw Exception('LessonModel:init, init voiceService failed');
    }
    _releaseLock();
  }

  Future<void> startListening() async {
    debugPrint('lesson_model:startListening');

    if (!_takeLock()) {
      return;
    }

    _checkStatus([ExerciseStatus.ReadyForFirstAnswer, ExerciseStatus.OnAnswerFeedback]);

    var before = _state;

    _updateState(LessonState(
        ratioCompleted,
        ExerciseState(_currentExerciseOrNull!, _state.currentExerciseOrNull!.lastAnswerOrNull,
            ExerciseStatus.WaitForListeningAvailable, null),
        LessonStatus.OnLessonItem));

    bool startedOk = await _voiceService.startListening();

    if (startedOk) {
      _updateState(LessonState(
          ratioCompleted,
          ExerciseState(_currentExerciseOrNull!, _state.currentExerciseOrNull!.lastAnswerOrNull,
              ExerciseStatus.ListeningAnswer, null),
          LessonStatus.OnLessonItem));
    } else {
      _updateState(before); // it failed, so we come back to whatever the previous state was
    }

    _releaseLock();
  }

  Future<void> stopListening() async {
    debugPrint('lesson_model:stopListening');

    if (!_takeLock()) {
      return;
    }

    // 1) mark status as WaitForAnswerResult
    _updateState(LessonState(
        ratioCompleted,
        ExerciseState(_currentExerciseOrNull!, _state.currentExerciseOrNull!.lastAnswerOrNull,
            ExerciseStatus.WaitForAnswerResult, null),
        LessonStatus.OnLessonItem));

    // 2) stop listening
    String? result = await _voiceService.stopListening();

    if (result == null || result.isEmpty) {
      // non result => back to previous state
      _updateToPreviousAnswerState();
    } else {
      if (_state.currentExerciseOrNull!.lastAnswerOrNull == null) {
        // if first reply ot translation exercise => ask for confirmation
        final normalizedExpectedSentence = _normalizeString(_currentExerciseOrNull!.sentence.sentence);
        final normalizedVoiceResult = _normalizeString(result);
        // for now, the "tolerant" STT equals expected reply
        // we still need a "tolerant" reply if it's not good (by tolerant matching word-by-word)
        var answerQuality = _getAnswerStatusWithVoiceResult(normalizedExpectedSentence, normalizedVoiceResult);

        WaitingAnswer waitingAnswer = WaitingAnswer(
            result, answerQuality == _AnswerQuality.Bad ? result : _currentExerciseOrNull!.sentence.sentence);
        _updateState(LessonState(
            ratioCompleted,
            ExerciseState(_currentExerciseOrNull!, _state.currentExerciseOrNull!.lastAnswerOrNull,
                ExerciseStatus.ConfirmOrCancel, waitingAnswer),
            LessonStatus.OnLessonItem));
      } else {
        _updateToNewOnAnswerFeedback(result);
      }
    }

    _releaseLock();
  }

  void _updateToPreviousAnswerState() {
    // non result => back to previous state
    bool firstAnswer = _state.currentExerciseOrNull!.lastAnswerOrNull == null;
    _updateState(LessonState(
        ratioCompleted,
        ExerciseState(_currentExerciseOrNull!, _state.currentExerciseOrNull!.lastAnswerOrNull,
            firstAnswer ? ExerciseStatus.ReadyForFirstAnswer : ExerciseStatus.OnAnswerFeedback, null),
        LessonStatus.OnLessonItem));
  }

  void confirmAnswer() {
    debugPrint('lesson_model:confirmAnswer');

    if (!_takeLock()) {
      return;
    }

    _updateToNewOnAnswerFeedback(_state.currentExerciseOrNull!.AnswerWaitingForConfirmationOrNull!.rawAnswer);

    _releaseLock();
  }

  void _updateToNewOnAnswerFeedback(String newRawAnswer) {
    AnswerResult newAnswerResult = _getNewAnswerResult(
        _currentExerciseOrNull!.sentence.sentence, newRawAnswer, _state.currentExerciseOrNull!.lastAnswerOrNull);

    _updateState(LessonState(
        ratioCompleted,
        ExerciseState(_currentExerciseOrNull!, newAnswerResult, ExerciseStatus.OnAnswerFeedback, null),
        LessonStatus.OnLessonItem));
  }

  void cancelAnswer() {
    debugPrint('lesson_model:cancelAnswer');

    if (!_takeLock()) {
      return;
    }
    _updateToPreviousAnswerState();
    _releaseLock();
  }

  void nextLessonItem() {
    _checkStatus([ExerciseStatus.OnAnswerFeedback]);

    if (!_takeLock()) {
      return;
    }

    if (_state.currentExerciseOrNull!.lastAnswerOrNull!.answerStatus ==
            AnswerStatus.CorrectAnswerBadPronunciationNoMoreTry ||
        _state.currentExerciseOrNull!.lastAnswerOrNull!.answerStatus ==
            AnswerStatus.CorrectAnswerCorrectPronunciation) {
      _remainingExercises.removeFirst();
      if (_remainingExercises.isEmpty) {
        _updateState(LessonState(1.0, null, LessonStatus.Completed));
      } else {
        _updateState(LessonState(
            ratioCompleted,
            ExerciseState(_currentExerciseOrNull!, null, ExerciseStatus.ReadyForFirstAnswer, null),
            LessonStatus.OnLessonItem));
      }
    } else {
      // bad answer
      _remainingExercises.addLast(_remainingExercises.removeFirst());
      _updateState(LessonState(
          ratioCompleted,
          ExerciseState(_currentExerciseOrNull!, null, ExerciseStatus.ReadyForFirstAnswer, null),
          LessonStatus.OnLessonItem));
    }

    _releaseLock();
  }

  void _checkStatus(List<ExerciseStatus> expectedStatus) {
    if (_state.status != LessonStatus.OnLessonItem || !expectedStatus.contains(_state.currentExerciseOrNull!.status)) {
      throw Exception('expected status $expectedStatus, but was ${_state.currentExerciseOrNull?.status}');
    }
  }

  static String _normalizeString(String original) {
    var normalized =
        original.toLowerCase().replaceAll(_normalizeStrRegex, ' ').replaceAll(_whiteSpaceRegex, ' ').trim();
    return normalized;
  }

  static _AnswerQuality _getAnswerStatusWithVoiceResult(String normalizedExpected, String normalizedResult) {
    if (normalizedExpected == normalizedResult) {
      return _AnswerQuality.Good;
    } else {
      var dist = _distance.normalizedDistance(normalizedResult, normalizedExpected);
      if (dist < _maxDistance) {
        debugPrint(
            "BadPronunciation because distance between correct '$normalizedExpected' and reply '$normalizedResult' is $dist");
        return _AnswerQuality.GoodResultBadPronunciation;
      } else {
        debugPrint(
            "BadAnswer because distance between correct '$normalizedExpected' and reply '$normalizedResult' is $dist");
        return _AnswerQuality.Bad;
      }
    }
  }

  // TO solve BadPronunciation because distance between correct 'bà bà' and reply 'ba bà' is 0.2
  static List<AnswerPart> _getAnswerParts(String normalizedExpected, String normalizedResult) {
    final splitExpected = normalizedExpected.split(' ');
    final splitResult = normalizedResult.split(' ').toSet();

    var list = splitExpected.map((String e) => AnswerPart(e + ' ', splitResult.contains(e))).toList();
    return list;
  }

  static AnswerResult _getNewAnswerResult(String expectedSentence, String voiceResult, AnswerResult? lastAnswerOrNull) {
    final normalizedExpectedSentence = _normalizeString(expectedSentence);
    final normalizedVoiceResult = _normalizeString(voiceResult);

    var answerQuality = _getAnswerStatusWithVoiceResult(normalizedExpectedSentence, normalizedVoiceResult);
    final answerParts = _getAnswerParts(normalizedExpectedSentence, normalizedVoiceResult);

    switch (answerQuality) {
      case _AnswerQuality.Good:
        return AnswerResult(voiceResult, answerParts, AnswerStatus.CorrectAnswerCorrectPronunciation, null);
      case _AnswerQuality.GoodResultBadPronunciation:
        if (lastAnswerOrNull == null) {
          return AnswerResult(
              voiceResult, answerParts, AnswerStatus.CorrectAnswerBadPronunciation, _nbTryForPronunciation);
        } else if (lastAnswerOrNull.answerStatus == AnswerStatus.CorrectAnswerBadPronunciation) {
          if (lastAnswerOrNull.remainingTryIfBadPronunciationOrNull == 1) {
            return AnswerResult(voiceResult, answerParts, AnswerStatus.CorrectAnswerBadPronunciationNoMoreTry, 0);
          } else {
            return AnswerResult(voiceResult, answerParts, AnswerStatus.CorrectAnswerBadPronunciation,
                lastAnswerOrNull.remainingTryIfBadPronunciationOrNull! - 1);
          }
        } else {
          throw Exception(
              "LessonModel:_getNewAnswerResult invalid state, lastAnswerStatus is '${lastAnswerOrNull.answerStatus}'");
        }
      case _AnswerQuality.Bad:
        if (lastAnswerOrNull == null) {
          return AnswerResult(voiceResult, answerParts, AnswerStatus.BadAnswer, null);
        } else if (lastAnswerOrNull.answerStatus == AnswerStatus.CorrectAnswerBadPronunciation) {
          if (lastAnswerOrNull.remainingTryIfBadPronunciationOrNull == 1) {
            return AnswerResult(voiceResult, answerParts, AnswerStatus.CorrectAnswerBadPronunciationNoMoreTry, 0);
          } else {
            return AnswerResult(voiceResult, answerParts, AnswerStatus.CorrectAnswerBadPronunciation,
                lastAnswerOrNull.remainingTryIfBadPronunciationOrNull! - 1);
          }
        } else {
          throw Exception(
              "LessonModel:_getNewAnswerResult invalid state, lastAnswerStatus is '${lastAnswerOrNull.answerStatus}'");
        }
    }
  }
}
