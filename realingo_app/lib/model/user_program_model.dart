import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/services/texttospeech_service.dart';

class UserProgramModel extends ChangeNotifier {
  UserLearningProgram? _programOrNull;

  Future<void> reload() async {
    _programOrNull = await ProgramServices.getDefaultUserProgramOrNull();
    if (_programOrNull != null) {
      await TextToSpeech.loadSentences(_programOrNull!.program.learnedLanguageUri,
          List<Sentence>.unmodifiable(_programOrNull!.nextLesson.exercises.map<Sentence>((e) => e.sentence)));
    }

    notifyListeners();
  }

  UserLearningProgram? get programOrNull => _programOrNull;
}
