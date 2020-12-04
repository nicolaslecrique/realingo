import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceServiceStatus { Initializing, Ready, Starting, Listening, Stopping, Error }

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  void Function(VoiceServiceStatus status) _onStatusChangedCallback;
  void Function(String result) _onResultCallback;
  VoiceServiceStatus _status = VoiceServiceStatus.Initializing;
  static VoiceService _instance;

  // we make a singleton because _speech.initialize should be called only once
  VoiceService._constructor();

  factory VoiceService.get() {
    if (_instance == null) {
      _instance = VoiceService._constructor();
      _instance._speech.initialize(onStatus: _instance._statusListener, onError: _instance._errorListener).then(
          (isOk) => isOk
              ? _instance._onStatusChanged(VoiceServiceStatus.Ready)
              : _instance._onStatusChanged(VoiceServiceStatus.Error));
    }
    return _instance;
  }

  void register(
      void Function(VoiceServiceStatus status) onStatusChangedCallback, void Function(String result) onResultCallback) {
    _onStatusChangedCallback = onStatusChangedCallback;
    _onResultCallback = onResultCallback;
    _onStatusChangedCallback(_status);
  }

  void unregister() {
    _onStatusChangedCallback = null;
    _onResultCallback = null;
  }

  void _onStatusChanged(VoiceServiceStatus status) {
    _status = status;
    if (_onStatusChangedCallback != null) {
      _onStatusChangedCallback(_status);
    }
  }

  void _onResult(String result) {
    if (_onResultCallback != null) {
      _onResultCallback(result);
    }
  }

  /*
  Future<String> _getLocalId(Language language) async {
    List<stt.LocaleName> list = await _speech.locales();
    return "viet";
  }*/

  // only called from error to "listen" function, so it's only a recognize error (i.e. : no one spoke)
  void _errorListener(SpeechRecognitionError errorNotification) {
    print(errorNotification.toString());
    _onResult('');
  }

  void _statusListener(String status) {
    //print("_statusListener:" + status);
    if (status == 'listening') {
      _onStatusChanged(VoiceServiceStatus.Listening);
    } else if (status == 'notListening') {
      _onStatusChanged(VoiceServiceStatus.Ready);
    }
  }

  void startListening() {
    _onStatusChanged(VoiceServiceStatus.Starting);
    //_getLocalId(null);

    _speech.listen(
        onResult: (SpeechRecognitionResult result) => {if (result.finalResult) _onResult(result.recognizedWords)},
        listenFor: Duration(seconds: 20),
        localeId: 'vi-VN',
        onSoundLevelChange: (double level) => null,
        cancelOnError: true,
        listenMode: ListenMode.deviceDefault);
  }

  void stopListening() {
    _onStatusChanged(VoiceServiceStatus.Stopping);
    _speech.stop().then((value) => _onStatusChanged(VoiceServiceStatus.Ready));
  }
}
