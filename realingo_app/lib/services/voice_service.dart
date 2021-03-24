import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  static VoiceService? _instance;

  // stop completer is completed
  // 1) false in case of error
  // 2) false in case of another start of stop call
  // 3) true in case of recognizedWords in listen
  // 4) after timeout
  Completer<String>? _stopCompleter;

  // start completer completed
  // 1) false in case of error
  // 2) false in case of another start of stop call
  // 3) true in case of statusListener change to "listening"
  // 4) after timeout
  Completer<bool>? _startCompleter;

  // true if init succeeded, else false
  Future<bool> init() async {
    return await _speech.initialize(onError: _errorListener, onStatus: _statusListener);
  }

  VoiceService._constructor();

  // we make a singleton because _speech.initialize should be called only once (callback are not used)
  factory VoiceService.get() {
    _instance ??= VoiceService._constructor();
    return _instance!;
  }

  // only called from error to "listen" function, so it's only a recognize error (i.e. : no one spoke)
  void _errorListener(SpeechRecognitionError errorNotification) {
    debugPrint(errorNotification.toString());
    _completeCompletersOnError();
  }

  // true if listening started, false if it failed
  Future<bool> startListening() async {
    debugPrint('========VoiceService:startListening==============');
    _completeCompletersOnError();

    if (!(_speech.isAvailable) || !(_speech.isNotListening)) {
      debugPrint(
          'VoiceService:startListening, not started because isAvailable=${_speech.isAvailable}, itNotListening=${_speech.isNotListening}');
      return Future.value(false);
    }
    Completer<bool> completer = Completer<bool>();
    _startCompleter = completer;
    await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          debugPrint(
              "VoiceService:startListening, final: ${result.finalResult}, new result: '${result.recognizedWords}'");
          if (result.finalResult) {
            if (_stopCompleter != null && !_stopCompleter!.isCompleted) {
              _stopCompleter!.complete(result.recognizedWords);
              _stopCompleter = null;
            }
          }
        },
        listenFor: Duration(seconds: 10),
        localeId: 'vi-VN',
        onSoundLevelChange: (double level) => null,
        cancelOnError: true,
        partialResults: false,
        listenMode: ListenMode.deviceDefault); // will trigger a status change to "listening"

    Timer(Duration(milliseconds: 500), () {
      // if not completed after 500ms, we return null
      if (!completer.isCompleted) {
        debugPrint('VoiceService:startListening, timeout');
        // in case no result is returned from listen or error
        _startCompleter = null;
        completer.complete(false);
      }
    });
    return completer.future;
  }

  void _statusListener(String status) {
    debugPrint('VoiceService:_statusListener, received status $status, _startCompleter=$_startCompleter');
    if (status == 'listening' && _startCompleter != null && !_startCompleter!.isCompleted) {
      debugPrint('VoiceService:_statusListener, complete _startCompleter');
      _startCompleter!.complete(true);
      _startCompleter = null;
    }
  }

  Future<String> stopListening() async {
    debugPrint('VoiceService:stopListening');

    _completeCompletersOnError();

    if (!_speech.isListening) {
      return Future.value(null);
    }
    Completer<String> completer = Completer<String>();
    _stopCompleter = completer;
    await _speech.stop();
    Timer(Duration(milliseconds: 1000), () {
      // if not completed after 100ms, we return null
      if (!completer.isCompleted) {
        // in case no result is returned from listen or error
        _stopCompleter = null;
        completer.complete(null);
      }
    });
    return completer.future;
  }

  void _completeCompletersOnError() {
    if (_stopCompleter != null && !_stopCompleter!.isCompleted) {
      debugPrint('VoiceService:_completeCompletersOnError, _stopCompleter');
      _stopCompleter!.complete(null);
    }
    if (_startCompleter != null && !_startCompleter!.isCompleted) {
      debugPrint('VoiceService:_completeCompletersOnError, _startCompleter');
      _startCompleter!.complete(false);
    }
    _stopCompleter = null;
    _startCompleter = null;
  }
}
