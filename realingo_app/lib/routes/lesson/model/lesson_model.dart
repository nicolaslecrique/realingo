import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';
import 'package:realingo_app/services/voice_service.dart';

import 'lesson_state.dart';

class LessonModel extends ChangeNotifier {
  // immutable fields
  final Language learnedLanguage;
  final List<LessonItem> _lessonItems;
  static final Levenshtein _distance = Levenshtein();
  static const double _maxDistance = 0.5;
  VoiceService _voiceService;
  static final RegExp _normalizeStrRegex = RegExp(r'[^\w\s]+');

  // internal current state
  LessonState _state;
  VoiceServiceStatus _voiceStatus; // initialized by _voiceService.register
  String _lastVoiceResultOrNull = null;
  Queue<LessonItem> _remainingItems;

  LessonItem get _currentItemOrNull => _remainingItems.isEmpty ? null : _remainingItems.first;
  LessonState get state => _state;
  double get ratioCompleted => (_lessonItems.length - _remainingItems.length).toDouble() / _lessonItems.length;

  LessonModel(this.learnedLanguage, this._lessonItems) {
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
    _checkStatus([LessonItemStatus.ReadyForAnswer, LessonItemStatus.CorrectAnswerBadPronunciation]);
    _voiceService.startListening();
  }

  void stopListening() {
    debugPrint('lesson_model:stopListening');
    _checkStatus([LessonItemStatus.ListeningAnswer]);
    _voiceService.stopListening();
  }

  void nextLessonItem() {
    _checkStatus([
      LessonItemStatus.BadAnswer,
      LessonItemStatus.CorrectAnswerBadPronunciation, // mark card as OK
      LessonItemStatus.CorrectAnswerCorrectPronunciation
    ]);

    if (_state.currentItemOrNull.status == LessonItemStatus.CorrectAnswerBadPronunciation ||
        _state.currentItemOrNull.status == LessonItemStatus.CorrectAnswerCorrectPronunciation) {
      _remainingItems.removeFirst();
      if (_remainingItems.isEmpty) {
        _voiceService.unregister();
      }
    } else {
      // bad answer
      _remainingItems.addLast(_remainingItems.removeFirst());
    }
    _lastVoiceResultOrNull = null;
    _recomputeState(nextItem: true);
  }

  void _onVoiceResult(String result) {
    if (result == null || result.isEmpty) {
      // if we get no valid result we just ignore it
      return;
    }
    _lastVoiceResultOrNull = result;
    _recomputeState();
  }

  void _onVoiceStatusChanged(VoiceServiceStatus status) {
    _voiceStatus = status;
    _recomputeState();
  }

  void _recomputeState({bool nextItem = false}) {
    _state = _getNewState(nextItem);
    notifyListeners();
  }

  LessonState _getNewState(bool nextItem) {
    if (nextItem) {
      if (_remainingItems.isEmpty) {
        return LessonState(1.0, null, LessonStatus.Completed);
      } else {
        // new item
        return LessonState(ratioCompleted, LessonItemState(_currentItemOrNull, null, LessonItemStatus.ReadyForAnswer),
            LessonStatus.OnLessonItem);
      }
    } else if (_voiceStatus == VoiceServiceStatus.Initializing) {
      return LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady);
    } else {
      LessonItemState newItemState = _getItemNewState();
      return LessonState(ratioCompleted, newItemState, LessonStatus.OnLessonItem);
    }
  }

  LessonItemState _getItemNewState() {
    if (_voiceStatus == VoiceServiceStatus.Ready) {
      if (_lastVoiceResultOrNull == null) {
        return LessonItemState(_currentItemOrNull, null, LessonItemStatus.ReadyForAnswer);
      } else {
        var itemStatus = _getItemStatusWithVoiceResult(_currentItemOrNull.sentence.sentence, _lastVoiceResultOrNull);
        final answerParts = _getAnswerResult(_currentItemOrNull.sentence.sentence, _lastVoiceResultOrNull);
        return LessonItemState(_currentItemOrNull, AnswerResult(_lastVoiceResultOrNull, answerParts), itemStatus);
      }
    } else {
      var itemStatus = _getItemStatusWithVoiceStatus(_voiceStatus);
      return LessonItemState(
          _currentItemOrNull,
          _lastVoiceResultOrNull == null
              ? null
              : AnswerResult(_lastVoiceResultOrNull,
                  _getAnswerResult(_currentItemOrNull.sentence.sentence, _lastVoiceResultOrNull)),
          itemStatus);
    }
  }

  static LessonItemStatus _getItemStatusWithVoiceStatus(VoiceServiceStatus status) {
    switch (status) {
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

  static LessonItemStatus _getItemStatusWithVoiceResult(String expectedSentence, String voiceResult) {
    final normalizedExpected = _normalizeString(expectedSentence);
    final normalizedResult = _normalizeString(voiceResult);
    if (normalizedExpected == normalizedResult) {
      return LessonItemStatus.CorrectAnswerCorrectPronunciation;
    } else if (_distance.normalizedDistance(normalizedResult, normalizedExpected) < _maxDistance) {
      return LessonItemStatus.CorrectAnswerBadPronunciation;
    } else {
      return LessonItemStatus.BadAnswer;
    }
  }

  static List<AnswerPart> _getAnswerResult(String expectedSentence, String voiceResult) {
    final splitExpected = expectedSentence.split(' ');
    final splitResult = _normalizeString(voiceResult).split(' ').toSet();

    var list = splitExpected.map((String e) => AnswerPart(e + ' ', splitResult.contains(_normalizeString(e)))).toList();
    return list;
  }
}
