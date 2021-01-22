import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceServiceStatus {
  Initializing, // initializing service
  Ready, // ready to start record
  Starting, // starting record
  Listening, // recording
  Stopping, // stopping record
  Error // received error
}

enum VoiceServiceAction { StartListening, StopListening }

class VoiceServiceState {
  final VoiceServiceStatus status;
  final String newResultOrNull;

  const VoiceServiceState(this.status, this.newResultOrNull);

  @override
  bool operator ==(Object other) {
    VoiceServiceState otherState = other as VoiceServiceState;
    return status == otherState.status && newResultOrNull == otherState.newResultOrNull;
  }
}

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  void Function(VoiceServiceState state) _onStateChangedCallback;
  VoiceServiceState _state = VoiceServiceState(VoiceServiceStatus.Initializing, null);

  String _lastSttResultOrNull;
  String _lastSttStatusOrNull;
  bool _initializationOkOrNull;

  VoiceService() {
    _speech.initialize(onStatus: _statusListener, onError: _errorListener).then((isOk) {
      _initializationOkOrNull = isOk;
      _onStateChanged();
    });
  }

  void register(void Function(VoiceServiceState state) onStateChanged) {
    _onStateChangedCallback = onStateChanged;
    _onStateChangedCallback(_state); // on register, we send a snapshot of current state
  }

  void unregister() {
    _onStateChangedCallback = null;
  }

  VoiceServiceState computeNewState(VoiceServiceAction actionOrNull) {
    if (_initializationOkOrNull == null) {
      return VoiceServiceState(VoiceServiceStatus.Initializing, null);
    } else if (_initializationOkOrNull == false) {
      return VoiceServiceState(VoiceServiceStatus.Error, null);
    } else if (actionOrNull == null) {
      if (_lastSttStatusOrNull == 'listening') {
        return VoiceServiceState(VoiceServiceStatus.Listening, null);
      } else if ((_lastSttStatusOrNull == null) || (_lastSttStatusOrNull == 'notListening')) {
        // _lastSttStatusOrNull is null after initialization done (callback "notListening" not called)
        return VoiceServiceState(VoiceServiceStatus.Ready, _lastSttResultOrNull);
      }
    } else {
      switch (actionOrNull) {
        case VoiceServiceAction.StartListening:
          return VoiceServiceState(VoiceServiceStatus.Starting, null);
        case VoiceServiceAction.StopListening:
          return VoiceServiceState(VoiceServiceStatus.Stopping, null);
      }
    }
  }

  // TODO : faire un "stop" qui est async et retourne le resultat et basta

  void _onStateChanged({VoiceServiceAction actionOrNull}) {
    debugPrint(
        'VoiceService:_onStateChanged, action: $actionOrNull, _lastSttResultOrNull: $_lastSttResultOrNull, _lastSttStatusOrNull: $_lastSttStatusOrNull');
    VoiceServiceState newState = computeNewState(actionOrNull);
    if (newState != _state) {
      _state = newState;
      if (_onStateChangedCallback != null) {
        if (actionOrNull != null) {
          // if callback call is an action, we can call callbck right away
          debugPrint('VoiceService:_onStateChanged, notify new state: ${newState.status}/${newState.newResultOrNull}');
          _onStateChangedCallback(newState);
        } else {
          // else we delay callback by 100ms, if we get a new one within this time frame, we cancel the old one
          // it is because we might receive several "notListening" with result null events just before
          // the final result come. and a "notListening" with result null might also be the last one
          // so we wait a bit to know if it's the last one or not
          VoiceServiceState stateToUseForEvent = _state;
          Timer(Duration(milliseconds: 200), () => _triggerOnStateChangedIfNotOverridden(stateToUseForEvent));
        }
      }
    } else {
      debugPrint('VoiceService:_onStateChanged, no event sent because state kept the same');
    }
  }

  void _triggerOnStateChangedIfNotOverridden(VoiceServiceState state) {
    if (state != _state) {
      debugPrint('state has changed during the delaying time, so we cancel call to _onStateChangedCallback');
    } else {
      debugPrint('VoiceService:_onStateChanged, notify new state: ${state.status}/${state.newResultOrNull}');
      _onStateChangedCallback(state);
    }
  }

  /*
  Future<String> _getLocalId(Language language) async {
    List<stt.LocaleName> list = await _speech.locales();
    return "viet";
  }*/

  // only called from error to "listen" function, so it's only a recognize error (i.e. : no one spoke)
  void _errorListener(SpeechRecognitionError errorNotification) {
    debugPrint(errorNotification.toString());
    _lastSttResultOrNull = null;
    _onStateChanged();
  }

  void _statusListener(String status) {
    debugPrint('voice_service:_statusListener: $status, _lastSttResultOrNull: $_lastSttResultOrNull');
    _lastSttStatusOrNull = status;
    _onStateChanged();
  }

  void startListening() {
    debugPrint('VoiceService:startListening');
    _lastSttResultOrNull = null;
    _onStateChanged(actionOrNull: VoiceServiceAction.StartListening);

    _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          debugPrint(
              "VoiceService:startListening, final: ${result.finalResult}, new result: '${result.recognizedWords}'");
          _lastSttResultOrNull = result.recognizedWords;
          if (result.finalResult) {
            _onStateChanged();
          }
        },
        listenFor: Duration(seconds: 10),
        localeId: 'vi-VN',
        onSoundLevelChange: (double level) => null,
        cancelOnError: true,
        listenMode: ListenMode.deviceDefault); // will trigger a status change to "listening"
  }

  void stopListening() {
    debugPrint('VoiceService:stopListening');
    _onStateChanged(actionOrNull: VoiceServiceAction.StopListening);
    _speech.stop().then((value) => _onStateChanged());
    // we have to add the callback because the callback _statusListener
    // is not always called (if was not listening before)
  }
}
