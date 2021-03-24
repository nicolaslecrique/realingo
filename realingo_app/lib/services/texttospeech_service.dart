import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/rest/rest_api.dart';

class TextToSpeech {
  static Future<void> loadSentences(String languageUri, List<Sentence> sentences) async {
    final Directory directory = await getApplicationSupportDirectory();
    await Future.wait(sentences.map((e) => _loadOrGetSentenceRecordFilePath(directory, e, languageUri)));
  }

  static Future<void> play(String languageUri, Sentence sentence) async {
    final Directory directory = await getApplicationSupportDirectory();
    String path = await _loadOrGetSentenceRecordFilePath(directory, sentence, languageUri);
    await _playFromFile(path);
  }

  static Future<String> _loadOrGetSentenceRecordFilePath(
      Directory directory, Sentence sentence, String languageUri) async {
    String path = '${directory.absolute.path}/sentence_records/${sentence.uri}.wav';
    File file = File(path);
    if (!await file.exists()) {
      final Uint8List wavContent = await RestApi.getRecord(languageUri, sentence.sentence);
      await file.create(recursive: true); // in case sentence_records directory doesn't exist
      await file.writeAsBytes(wavContent, mode: FileMode.writeOnly, flush: true);
    }
    return path;
  }

  static Future<void> _playFromFile(String url) async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(url, isLocal: true);
  }
}
