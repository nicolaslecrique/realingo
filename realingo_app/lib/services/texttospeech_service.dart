import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/rest/rest_api.dart';
import 'package:realingo_app/tech_services/result.dart';

class TextToSpeech {
  static Future<Result<void>> loadSentences(String languageUri, List<Sentence> sentences) async {
    final Directory directory = await getApplicationSupportDirectory();
    final List<Result<String>> path =
        await Future.wait(sentences.map((e) => _loadOrGetSentenceRecordFilePath(directory, e, languageUri)));

    return Result.mergeList<void, String>(path, (_) => 0);
  }

  static Future<Result<void>> play(String languageUri, Sentence sentence) async {
    final Directory directory = await getApplicationSupportDirectory();
    Result<String> path = await _loadOrGetSentenceRecordFilePath(directory, sentence, languageUri);
    if (path.isOk) {
      await _playFromFile(path.result);
      return Result.ok(null);
    } else {
      return Result.ko(path.error);
    }
  }

  static Future<Result<String>> _loadOrGetSentenceRecordFilePath(
      Directory directory, Sentence sentence, String languageUri) async {
    String path = '${directory.absolute.path}/sentence_records/${sentence.uri}.wav';
    File file = File(path);
    if (!await file.exists()) {
      final Result<Uint8List> wavContent = await RestApi.getRecord(languageUri, sentence.sentence);
      if (wavContent.isOk) {
        await file.create(recursive: true); // in case sentence_records directory doesn't exist
        await file.writeAsBytes(wavContent.result, mode: FileMode.writeOnly, flush: true);
      } else {
        return Result.ko(AppError.RestRequestFailed);
      }
    }
    return Result.ok(path);
  }

  static Future<void> _playFromFile(String url) async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(url, isLocal: true);
  }
}
