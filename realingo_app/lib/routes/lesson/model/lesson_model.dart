import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/foundation.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';
import 'package:realingo_app/services/voice_service.dart';

import 'lesson_states.dart';

class LessonModel extends ChangeNotifier {
  // immutable fields
  final List<LessonItem> _lessonItems;
  static final Levenshtein _distance = Levenshtein();
  static const double _maxDistance = 0.1;
  VoiceService _voiceService;
  static final RegExp _normalizeStrRegex = RegExp(r'[^\w\s]+');

  // internal current state
  int _currentLessonItemIndex = 0;
  LessonState _state;
  VoiceServiceStatus _voiceStatus; // initialized by _voiceService.register
  String _voiceResult = '';

  // getter helper
  double get _ratioCompleted => _currentLessonItemIndex.toDouble() / _lessonItems.length;
  LessonItem get _currentItem => _lessonItems[_currentLessonItemIndex];

  LessonModel(this._lessonItems) {
    _state = WaitForAnswer(0.0, _lessonItems[_currentLessonItemIndex], null);
    _voiceService = VoiceService.get();
    _voiceService.register(_onVoiceStatusChanged, _onVoiceResult);
  }

  LessonState get state => _state;

  void startListening() {
    debugPrint('lesson_model:startListening');
    if (_state is WaitForAnswer) {
      _voiceService.startListening();
    } else {
      throw Exception('startListening should only be called if state is not WaitForAnswer, but was ${_state}');
    }
  }

  void stopListening() {
    debugPrint('lesson_model:startListening');
    if (_state is ListeningAnswer) {
      _voiceService.stopListening();
    } else {
      throw Exception('stopListening should only be called if state is not ListeningAnswer, but was ${_state}');
    }
  }

  void nextLessonItem() {
    if (_state is CorrectAnswer) {
      _recomputeState(true);
    } else {
      throw Exception('nextLessonItem should only be called if state is not CorrectAnswer, but was ${_state}');
    }
  }

  void _onVoiceResult(String result) {
    _voiceResult = result;
    _recomputeState(false);
  }

  void _onVoiceStatusChanged(VoiceServiceStatus status) {
    _voiceStatus = status;
    _recomputeState(false);
  }

  void _recomputeState(bool nextLesson) {
    _state = _getNewState(nextLesson);
    notifyListeners();
  }

  LessonState _getNewState(bool nextLesson) {
    if (nextLesson) {
      if (_currentLessonItemIndex == _lessonItems.length - 1) {
        _voiceService.unregister();
        return EndOfLesson();
      } else {
        _currentLessonItemIndex++;
        _voiceResult = '';
        return _getNewState(false);
      }
    }

    if (_isVoiceResultCorrect()) {
      return CorrectAnswer(_ratioCompleted, _currentItem, AnswerResult(_voiceResult));
    } else {
      switch (_voiceStatus) {
        case VoiceServiceStatus.Initializing:
          return WaitForVoiceServiceReady(_ratioCompleted);
        case VoiceServiceStatus.Ready:
          return WaitForAnswer(_ratioCompleted, _currentItem, AnswerResult(_voiceResult));
        case VoiceServiceStatus.Starting:
          return WaitForListeningAvailable(_ratioCompleted, _currentItem);
        case VoiceServiceStatus.Listening:
          return ListeningAnswer(_ratioCompleted, _currentItem);
        case VoiceServiceStatus.Stopping:
          return WaitForAnswerResult(_ratioCompleted, _currentItem);
        default:
          throw Exception(
              '_recomputeState: unexpected combination of voice service status $_voiceStatus and voice result $_voiceResult');
      }
    }
  }

  static String _normalizeString(String original) {
    // https://stackoverflow.com/questions/53239702/how-to-remove-only-symbols-from-string-in-dart
    return original.toLowerCase().trim().replaceAll(_normalizeStrRegex, '');
  }

  bool _isVoiceResultCorrect() {
    final expected = _normalizeString(_lessonItems[_currentLessonItemIndex].sentence.sentence);
    final normalizedResult = _normalizeString(_voiceResult);
    final dist = _distance.normalizedDistance(normalizedResult, expected);
    return dist < _maxDistance;
  }
}
