import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';
import 'package:realingo_app/services/voice_service.dart';

import 'lesson_state.dart';

class SentenceWithNormalization {
  final String rawSentence;
  final String normalizedSentence;

  const SentenceWithNormalization(this.rawSentence, this.normalizedSentence);
}

class LessonModel extends ChangeNotifier {
  // immutable fields
  final Language learnedLanguage;
  final List<LessonItem> _lessonItems;
  static final Levenshtein _distance = Levenshtein();
  static const double _maxDistance = 0.5;
  VoiceService _voiceService;
  // https://stackoverflow.com/questions/15531928/matching-unicode-letters-with-regexp
  static final RegExp _normalizeStrRegex = RegExp(r'[^\p{L}]+', unicode: true);
  static final RegExp _whiteSpaceRegex = RegExp(r'[ ]+');

  // internal current state
  LessonState _state;
  VoiceServiceState _voiceServiceState; // initialized by _voiceService.register
  SentenceWithNormalization _lastVoiceResultOrNull = null;
  Queue<LessonItem> _remainingItems;

  LessonItem get _currentItemOrNull => _remainingItems.isEmpty ? null : _remainingItems.first;
  LessonState get state => _state;
  double get ratioCompleted => (_lessonItems.length - _remainingItems.length).toDouble() / _lessonItems.length;

  LessonModel(this.learnedLanguage, this._lessonItems) {
    _remainingItems = QueueList<LessonItem>.from(_lessonItems);
    _state = LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady);
    _voiceService = VoiceService.get();
    _voiceService.register(_onVoiceStateChanged);
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

  void _onVoiceStateChanged(VoiceServiceState state) {
    _voiceServiceState = state;
    if (state.status == VoiceServiceStatus.Ready) {
      // if voiceStatus si "ready", we suppose that this result replace the previous one
      // even if this result is null. This solve the following issue:
      // 1) voiceService return "Ready/result=null" for half a second
      // 2) then finally Ready/result=voice_result
      // if we don't set _lastVoiceResultOrNull to null we show the previous result on the screen for this time.
      // then blink to the correct reply when voice_result comes
      if (_state.currentItemOrNull == null) {
        _lastVoiceResultOrNull = null;
      } else {
        _lastVoiceResultOrNull =
            SentenceWithNormalization(state.newResultOrNull, _normalizeString(state.newResultOrNull));
      }
    }
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
    } else if (_voiceServiceState.status == VoiceServiceStatus.Initializing) {
      return LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady);
    } else {
      LessonItemState newItemState = _getItemNewState();
      return LessonState(ratioCompleted, newItemState, LessonStatus.OnLessonItem);
    }
  }

  LessonItemState _getItemNewState() {
    if (_voiceServiceState.status == VoiceServiceStatus.Ready) {
      if (_lastVoiceResultOrNull == null) {
        return LessonItemState(_currentItemOrNull, null, LessonItemStatus.ReadyForAnswer);
      } else {
        final normalizedExpectedSentence = _normalizeString(_currentItemOrNull.sentence.sentence);

        var itemStatus =
            _getItemStatusWithVoiceResult(normalizedExpectedSentence, _lastVoiceResultOrNull.normalizedSentence);
        final answerParts = _getAnswerResult(normalizedExpectedSentence, _lastVoiceResultOrNull.normalizedSentence);
        return LessonItemState(
            _currentItemOrNull, AnswerResult(_lastVoiceResultOrNull.rawSentence, answerParts), itemStatus);
      }
    } else {
      var itemStatus = _getItemStatusWithVoiceStatus(_voiceServiceState.status);
      final normalizedExpectedSentence = _normalizeString(_currentItemOrNull.sentence.sentence);
      return LessonItemState(
          _currentItemOrNull,
          _lastVoiceResultOrNull == null
              ? null
              : AnswerResult(_lastVoiceResultOrNull.rawSentence,
                  _getAnswerResult(normalizedExpectedSentence, _lastVoiceResultOrNull.normalizedSentence)),
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
    var normalized =
        original.toLowerCase().replaceAll(_normalizeStrRegex, ' ').replaceAll(_whiteSpaceRegex, ' ').trim();
    return normalized;
  }

  static LessonItemStatus _getItemStatusWithVoiceResult(String normalizedExpected, String normalizedResult) {
    if (normalizedExpected == normalizedResult) {
      return LessonItemStatus.CorrectAnswerCorrectPronunciation;
    } else {
      var dist = _distance.normalizedDistance(normalizedResult, normalizedExpected);
      if (dist < _maxDistance) {
        debugPrint(
            "BadPronunciation because distance between correct '$normalizedExpected' and reply '$normalizedResult' is $dist");
        return LessonItemStatus.CorrectAnswerBadPronunciation;
      } else {
        debugPrint(
            "BadAnswer because distance between correct '$normalizedExpected' and reply '$normalizedResult' is $dist");
        return LessonItemStatus.BadAnswer;
      }
    }
  }

  // TO solve BadPronunciation because distance between correct 'bà bà' and reply 'ba bà' is 0.2
  static List<AnswerPart> _getAnswerResult(String normalizedExpected, String normalizedResult) {
    final splitExpected = normalizedExpected.split(' ');
    final splitResult = normalizedResult.split(' ').toSet();

    var list = splitExpected.map((String e) => AnswerPart(e + ' ', splitResult.contains(e))).toList();
    return list;
  }
}

/*

TODO NICO JE RECUPERE DES RESULTATS INTERMEDIAIRE DE LA VOICE => CA FAIT BLINKER LA GUI C EST MOCHE

flutter: lesson state changed to LessonStatus.OnLessonItem/LessonItemStatus.CorrectAnswerBadPronunciation
flutter: BadAnswer because distance between correct 'bà bà' and reply 'bả' is 0.8
flutter: lesson state changed to LessonStatus.OnLessonItem/LessonItemStatus.BadAnswer
flutter: BadPronunciation because distance between correct 'bà bà' and reply 'bả bả' is 0.4
flutter: BadPronunciation because distance between correct 'bà bà' and reply 'bả bả' is 0.4
flutter: lesson state changed to LessonStatus.OnLessonItem/LessonItemStatus.CorrectAnswerBadPronunciation
 */
// TODO Gerer les 3 essais pour améliorer sa prononciation => sinon desfois on peut pas sortir
// si on est passé en mode "pronunciation", on doit pas pouvoir revenir en mode "mauvaise réponse"
