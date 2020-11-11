import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/tech_services/db.dart';

class UserProgram {
  final String uri;
  final LearningProgram program;

  UserProgram(this.uri, this.program);
}

class UserProgramServices {
  static String getCurrentUserProgramUriOrNull() {
    return Db.getCurrentUserProgramUriOrNull();
  }

  static Future<void> setCurrentUserProgramUri(String uri) async {
    return Db.setCurrentUserProgramUri(uri);
  }

  static Future<void> initUserProgram(Language originLanguage, Language targetLanguage) async {
    final program = await ProgramServices.getProgram(targetLanguage, originLanguage);

    await Db.setLearningProgram(DbLearningProgram(
        program.uri, program.itemsToLearn.map((e) => DbItemToLearn(e.uri, e.itemLabel)).toList(growable: false)));
    String userProgramUri = program.uri + "-" + DateTime.now().toIso8601String();
    DbUserProgram userProgram = DbUserProgram(userProgramUri, program.uri);
    await Db.setUserProgram(userProgram);
    await Db.setCurrentUserProgramUri(userProgram.uri);
    return;
  }

  static UserProgram getCurrentUserProgram() {
    String userProgramUri = Db.getCurrentUserProgramUriOrNull();
    DbUserProgram dbUserProgram = Db.getUserProgram(userProgramUri);
    LearningProgram learningProgram = ProgramServices.getCachedProgram(dbUserProgram.learningProgramUri);
    return UserProgram(dbUserProgram.uri, learningProgram);
  }
}
