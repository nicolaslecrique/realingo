import 'package:audioplayers/audio_cache.dart';

class Sound {
  static AudioCache player = AudioCache(prefix: 'assets/sounds/');

  static Future<void> GoodAnswer() async {
    await player.play('good_answer.mp3');
  }

  static Future<void> WrongAnswer() async {
    await player.play('wrong_answer.mp3');
  }
}
