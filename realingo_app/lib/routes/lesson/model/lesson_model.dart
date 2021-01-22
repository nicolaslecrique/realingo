import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';
import 'package:realingo_app/services/voice_service.dart';

import 'lesson_state.dart';

enum _AnswerQuality { Good, GoodResultBadPronunciation, Bad }

class LessonModel extends ChangeNotifier {
  // immutable fields
  final Language learnedLanguage;
  final List<LessonItem> _lessonItems;
  static final Levenshtein _distance = Levenshtein();
  static const double _maxDistance = 0.5;
  static const int _nbTryForPronunciation = 3;
  VoiceService _voiceService;
  // https://stackoverflow.com/questions/15531928/matching-unicode-letters-with-regexp
  static final RegExp _normalizeStrRegex = RegExp(r'[^\p{L}]+', unicode: true);
  static final RegExp _whiteSpaceRegex = RegExp(r'[ ]+');

  // internal current state
  LessonState _state;
  Queue<LessonItem> _remainingItems;

  // getters on current state
  LessonItem get _currentItemOrNull => _remainingItems.isEmpty ? null : _remainingItems.first;
  LessonState get state => _state;
  double get ratioCompleted => (_lessonItems.length - _remainingItems.length).toDouble() / _lessonItems.length;

  LessonModel(this.learnedLanguage, this._lessonItems) {
    _remainingItems = QueueList<LessonItem>.from(_lessonItems);
    _state = LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady);
    _voiceService = VoiceService();
    _voiceService.register(_onVoiceStateChanged);
  }

  void _checkStatus(List<LessonItemStatus> expectedStatus) {
    if (_state.status != LessonStatus.OnLessonItem || !expectedStatus.contains(_state.currentItemOrNull.status)) {
      throw Exception('expected status $expectedStatus, but was ${_state.currentItemOrNull?.status}');
    }
  }

  void startListening() {
    debugPrint('lesson_model:startListening');
    _checkStatus([LessonItemStatus.ReadyForFirstAnswer, LessonItemStatus.OnAnswerFeedback]);
    _voiceService.startListening();
  }

  void stopListening() {
    debugPrint('lesson_model:stopListening');
    _voiceService.stopListening();
  }

  void nextLessonItem() {
    _checkStatus([LessonItemStatus.OnAnswerFeedback]);

    if (_state.currentItemOrNull.lastAnswerOrNull.answerStatus == AnswerStatus.CorrectAnswerBadPronunciationNoMoreTry ||
        _state.currentItemOrNull.lastAnswerOrNull.answerStatus == AnswerStatus.CorrectAnswerCorrectPronunciation) {
      _remainingItems.removeFirst();
      if (_remainingItems.isEmpty) {
        _voiceService.unregister();
      }
    } else {
      // bad answer
      _remainingItems.addLast(_remainingItems.removeFirst());
    }
    _recomputeState(nextItem: true);
  }

  void _onVoiceStateChanged(VoiceServiceState state) {
    _recomputeState(newVoiceStateOrNull: state);
  }

  void _recomputeState({bool nextItem = false, VoiceServiceState newVoiceStateOrNull}) {
    _state = _getNewState(nextItem, newVoiceStateOrNull);
    debugPrint(
        'LessonModel:_recomputeState, new State is ${_state.status}/${_state.currentItemOrNull?.status}/${_state.currentItemOrNull?.lastAnswerOrNull?.answerStatus}');
    notifyListeners();
  }

  LessonState _getNewState(bool nextItem, VoiceServiceState newVoiceStateOrNull) {
    if (nextItem == false && newVoiceStateOrNull == null) {
      throw Exception('lesson_model: nextItem is false and newVoiceStateOrNull null');
    }

    if (nextItem) {
      if (_remainingItems.isEmpty) {
        return LessonState(1.0, null, LessonStatus.Completed);
      } else {
        // new item
        return LessonState(ratioCompleted,
            LessonItemState(_currentItemOrNull, null, LessonItemStatus.ReadyForFirstAnswer), LessonStatus.OnLessonItem);
      }
    } else if (newVoiceStateOrNull.status == VoiceServiceStatus.Initializing) {
      return LessonState(0.0, null, LessonStatus.WaitForVoiceServiceReady);
    } else {
      LessonItemState newItemState = _getItemNewState(newVoiceStateOrNull);
      return LessonState(ratioCompleted, newItemState, LessonStatus.OnLessonItem);
    }
  }

  //TODO NICO ERREUR DE RAISONNEMENT, ON PEUT PAS SE BASER SUR LE "LAST_STATE"
  // EN FAIT C'est qu'il y a 2 niveau, un niveau suite de réponses, un niveau "status dans la réponse courante

  // PB central: si voice is Ready avec resultat null: on ne sait pas si
  // 1) il n'y a pas eu d'enregistrement, et donc il faut revenir au stade précédent
  // 2) on est juste en attente une fraction de secondes, et donc il faut juste comme si on était tojours
  //    en mode WaitForAnswerResult

  LessonItemState _getItemNewState(VoiceServiceState voiceServiceState) {
    if (voiceServiceState.status == VoiceServiceStatus.Ready) {
      if (voiceServiceState.newResultOrNull == null || voiceServiceState.newResultOrNull.isEmpty) {
        if (_state.currentItemOrNull == null || _state.currentItemOrNull.lastAnswerOrNull == null) {
          // we were not on a item before, or no response yet, we set the item and mark ReadyForFirstAnswer
          return LessonItemState(_currentItemOrNull, null, LessonItemStatus.ReadyForFirstAnswer);
        } else {
          // voice result null with previous reply, we just keep the same lastAnswer
          return LessonItemState(
              _currentItemOrNull, _state.currentItemOrNull.lastAnswerOrNull, LessonItemStatus.OnAnswerFeedback);
        }
      } else {
        AnswerResult newAnswerResult = _getNewAnswerResult(_currentItemOrNull.sentence.sentence,
            voiceServiceState.newResultOrNull, _state.currentItemOrNull.lastAnswerOrNull);
        return LessonItemState(_currentItemOrNull, newAnswerResult, LessonItemStatus.OnAnswerFeedback);
      }
    } else {
      var itemStatus = _getItemStatusWithVoiceStatus(voiceServiceState.status);
      return LessonItemState(_currentItemOrNull, _state.currentItemOrNull.lastAnswerOrNull, itemStatus);
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

  // ignore: missing_return
  AnswerResult _getNewAnswerResult(String expectedSentence, String voiceResult, AnswerResult lastAnswerOrNull) {
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
                lastAnswerOrNull.remainingTryIfBadPronunciationOrNull - 1);
          }
        } else {
          throw Exception(
              "LessonModel:_getNewAnswerResult invalid state, lastAnswerStatus is '${lastAnswerOrNull.answerStatus}'");
        }
        break; // useless, just to shut up compiler
      case _AnswerQuality.Bad:
        if (lastAnswerOrNull == null) {
          return AnswerResult(voiceResult, answerParts, AnswerStatus.BadAnswer, null);
        } else if (lastAnswerOrNull.answerStatus == AnswerStatus.CorrectAnswerBadPronunciation) {
          if (lastAnswerOrNull.remainingTryIfBadPronunciationOrNull == 1) {
            return AnswerResult(voiceResult, answerParts, AnswerStatus.CorrectAnswerBadPronunciationNoMoreTry, 0);
          } else {
            return AnswerResult(voiceResult, answerParts, AnswerStatus.CorrectAnswerBadPronunciation,
                lastAnswerOrNull.remainingTryIfBadPronunciationOrNull - 1);
          }
        } else {
          throw Exception(
              "LessonModel:_getNewAnswerResult invalid state, lastAnswerStatus is '${lastAnswerOrNull.answerStatus}'");
        }
    }
  }
}
