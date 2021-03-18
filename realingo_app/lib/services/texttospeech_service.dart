import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/rest/rest_api.dart';

class TextToSpeech {
  static Future<void> play(Language language, Sentence sentence) async {
    final Directory directory = await getApplicationSupportDirectory();
    String path = '${directory.absolute.path}/sentence_records/${sentence.uri}.wav';
    File file = File(path);
    if (await file.exists()) {
      await _playFromFile(path);
    } else {
      final Uint8List wavContent = await RestApi.getRecord(language.uri, sentence.sentence);
      await file.create(recursive: true); // in case sentence_records directory doesn't exist
      await file.writeAsBytes(wavContent, mode: FileMode.writeOnly, flush: true);
      await _playFromFile(path);
    }
  }

  static Future<void> _playFromFile(String url) async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(url, isLocal: true);
  }
}
