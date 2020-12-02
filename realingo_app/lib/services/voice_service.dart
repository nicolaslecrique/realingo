import 'package:realingo_app/model/program.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceServiceStatus { Initializing, Ready, Starting, Listening, Stopping, Error }

class VoiceService {
  final stt.SpeechToText _speech;
  final void Function(VoiceServiceStatus status) _onStatusChanged;
  final void Function(String result) _onResult;
  String _localId;

  VoiceService(this._onStatusChanged, this._onResult, Language language) : _speech = stt.SpeechToText();

  Future<void> init() async {
    _onStatusChanged(VoiceServiceStatus.Initializing);

    _speech
        .initialize(onStatus: _statusListener, onError: _errorListener)
        .then((isOk) => isOk ? _onStatusChanged(VoiceServiceStatus.Ready) : _onStatusChanged(VoiceServiceStatus.Error));
  }

  Future<String> _getLocalId(Language language) async {
    List<stt.LocaleName> list = await _speech.locales();
    return "viet";
  }

  void _errorListener(SpeechRecognitionError errorNotification) {
    _onStatusChanged(VoiceServiceStatus.Error);
  }

  void _statusListener(String status) {
    if (status == "listening") {
      _onStatusChanged(VoiceServiceStatus.Listening);
    } else if (status == "notListening") {
      _onStatusChanged(VoiceServiceStatus.Ready);
    }

    print(status);
  }

  startListening() {
    _onStatusChanged(VoiceServiceStatus.Starting);

    //_getLocalId(null);

    _speech.listen(
        onResult: (SpeechRecognitionResult result) => {if (result.finalResult) _onResult(result.recognizedWords)},
        listenFor: Duration(seconds: 20),
        localeId: "vi-VN",
        onSoundLevelChange: (double level) => null,
        cancelOnError: true,
        listenMode: ListenMode.deviceDefault);
  }

  // return result
  void stopListening() {
    _onStatusChanged(VoiceServiceStatus.Stopping);
    _speech.stop();
  }
}
