import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';
import 'package:realingo_app/services/voice_service.dart';

import 'lesson_state.dart';

class LessonModel extends ChangeNotifier {
  // immutable fields
  final List<LessonItem> _lessonItems;
  static final Levenshtein _distance = Levenshtein();
  static const double _maxDistance = 0.25;
  VoiceService _voiceService;
  static final RegExp _normalizeStrRegex = RegExp(r'[^\w\s]+');

  // internal current state
  LessonState _state;
  VoiceServiceStatus _voiceStatus; // initialized by _voiceService.register
  String _voiceResult = '';
  Queue<LessonItem> _remainingItems;

  LessonItem get _currentItemOrNull => _remainingItems.isEmpty ? null : _remainingItems.first;
  LessonState get state => _state;
  double get ratioCompleted => (_lessonItems.length - _remainingItems.length).toDouble() / _lessonItems.length;

  LessonModel(this._lessonItems) {
    _remainingItems = QueueList<LessonItem>.from(_lessonItems);
    _state = LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady);
    _voiceService = VoiceService.get();
    _voiceService.register(_onVoiceStatusChanged, _onVoiceResult);
  }

  void _checkStatus(List<LessonItemStatus> expectedStatus) {
    if (_state.status != LessonStatus.OnLessonItem || !expectedStatus.contains(_state.currentItemOrNull.status)) {
      throw Exception('expected status $expectedStatus, but was ${_state.currentItemOrNull?.status}');
    }
  }

  void startListening() {
    debugPrint('lesson_model:startListening');
    _checkStatus([LessonItemStatus.ReadyForAnswer]);
    _voiceService.startListening();
  }

  void stopListening() {
    debugPrint('lesson_model:stopListening');
    _checkStatus([LessonItemStatus.ListeningAnswer]);
    _voiceService.stopListening();
  }

  void nextLessonItem() {
    _checkStatus([LessonItemStatus.CorrectAnswer, LessonItemStatus.CorrectAnswerNoHint]);

    if (_state.currentItemOrNull.status == LessonItemStatus.CorrectAnswerNoHint) {
      _remainingItems.removeFirst();
      if (_remainingItems.isEmpty) {
        _voiceService.unregister();
      }
    } else {
      _remainingItems.addLast(_remainingItems.removeFirst());
    }
    _voiceResult = '';
    _recomputeState(nextItem: true);
  }

  void askForHint() {
    _checkStatus([LessonItemStatus.ReadyForAnswer]);
    _recomputeState(nextHint: true);
  }

  void _onVoiceResult(String result) {
    _voiceResult = result;
    _recomputeState();
  }

  void _onVoiceStatusChanged(VoiceServiceStatus status) {
    _voiceStatus = status;
    _recomputeState();
  }

  void _recomputeState({bool nextItem: false, bool nextHint: false}) {
    _state = _getNewState(nextItem, nextHint);
    notifyListeners();
  }

  LessonState _getNewState(bool nextItem, bool nextHint) {
    if (nextItem) {
      if (_remainingItems.isEmpty) {
        return LessonState(1.0, null, LessonStatus.Completed);
      } else {
        // new item
        return LessonState(
            ratioCompleted,
            LessonItemState(_currentItemOrNull, _getFirstHint(_currentItemOrNull.sentence), AnswerResult(''),
                LessonItemStatus.ReadyForAnswer),
            LessonStatus.OnLessonItem);
      }
    } else if (_voiceStatus == VoiceServiceStatus.Initializing) {
      return LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady);
    } else {
      Hint currentHint =
          _state.currentItemOrNull != null ? _state.currentItemOrNull.hint : _getFirstHint(_currentItemOrNull.sentence);
      LessonItemState newItemState = _getItemNewState(nextHint, currentHint);
      return LessonState(ratioCompleted, newItemState, LessonStatus.OnLessonItem);
    }
  }

  LessonItemState _getItemNewState(bool nextHint, Hint currentHint) {
    if (_isVoiceResultCorrect(_currentItemOrNull.sentence.sentence, _voiceResult)) {
      if (currentHint.nbHintProvided == 0) {
        return LessonItemState(
            _currentItemOrNull, currentHint, AnswerResult(_voiceResult), LessonItemStatus.CorrectAnswerNoHint);
      } else {
        return LessonItemState(
            _currentItemOrNull, currentHint, AnswerResult(_voiceResult), LessonItemStatus.CorrectAnswer);
      }
    }
    if (nextHint) {
      return LessonItemState(_currentItemOrNull, _getNextHint(currentHint, _currentItemOrNull.sentence.sentence),
          AnswerResult(_voiceResult), LessonItemStatus.ReadyForAnswer);
    }

    return LessonItemState(_currentItemOrNull, currentHint, AnswerResult(_voiceResult), _getItemStatus(_voiceStatus));
  }

  static LessonItemStatus _getItemStatus(VoiceServiceStatus status) {
    switch (status) {
      case VoiceServiceStatus.Ready:
        return LessonItemStatus.ReadyForAnswer;
      case VoiceServiceStatus.Starting:
        return LessonItemStatus.WaitForListeningAvailable;
      case VoiceServiceStatus.Listening:
        return LessonItemStatus.ListeningAnswer;
      case VoiceServiceStatus.Stopping:
        return LessonItemStatus.WaitForAnswerResult;
      default:
        throw Exception('_recomputeState: unexpected voice service status $status');
    }
  }

  static String _normalizeString(String original) {
    // https://stackoverflow.com/questions/53239702/how-to-remove-only-symbols-from-string-in-dart
    return original.toLowerCase().trim().replaceAll(_normalizeStrRegex, '');
  }

  static bool _isVoiceResultCorrect(String expectedSentence, String voiceResult) {
    final expected = _normalizeString(expectedSentence);
    final normalizedResult = _normalizeString(voiceResult);
    final dist = _distance.normalizedDistance(normalizedResult, expected);
    return dist < _maxDistance;
  }

  static Hint _getNextHint(Hint previousHint, String sentence) {
    return Hint(sentence, previousHint.nbHintProvided + 1);
  }

  static Hint _getFirstHint(UserItemToLearnSentence sentence) {
    return Hint(sentence.hint, 0);
  }
}
