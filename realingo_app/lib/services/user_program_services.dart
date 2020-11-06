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

  static Future<String> initUserProgramReturnUri(
      Language originLanguage, Language targetLanguage) async {
    LearningProgram program =
        await ProgramServices.getProgram(targetLanguage, originLanguage);

    await Db.saveLearningProgram(DbLearningProgram(
        program.uri,
        program.itemsToLearn
            .map((e) => DbItemToLearn(e.uri, e.itemLabel))
            .toList(growable: false)));
    String userProgramUri =
        program.uri + "-" + DateTime.now().toIso8601String();
    DbUserProgram userProgram = DbUserProgram(userProgramUri, program.uri);

    await Db.saveUserProgram(userProgram);
    return userProgramUri;
  }
}
