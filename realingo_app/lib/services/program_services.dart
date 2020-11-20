import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/database/db.dart';
import 'package:realingo_app/tech_services/rest/rest_api.dart';
import 'package:realingo_app/tech_services/user_config.dart';

class ProgramServices {
  static Future<List<Language>> getAvailableTargetLanguages() async {
    return await RestApi.getAvailableLearnedLanguages();
  }

  static Future<List<Language>> getAvailableOriginLanguages(Language learnedLanguage) async {
    return await RestApi.getAvailableOriginLanguages(learnedLanguage.uri);
  }

  static Future<UserLearningProgram> buildUserProgram(Language learnedLanguage, Language originLanguage) async {
    final program = await RestApi.getProgram(learnedLanguage.uri, originLanguage.uri);

    final now = DateTime.now().toString();

    final userProgram = UserLearningProgram("${program.uri}-$now", program.uri,
        program.itemsToLearn.map((e) => UserItemToLearn("${e.uri}-$now", e, UserItemToLearnStatus.None)).toList());

    await db.insertUserLearningProgram(userProgram);

    UserConfig.setDefaultUserProgramUri(userProgram.uri);
    return userProgram;
  }

  static Future<UserLearningProgram> getDefaultUserProgramOrNull() async {
    String uri = await UserConfig.getDefaultUserProgramUriOrNull();
    if (uri != null) {
      return await db.getUserLearningProgram(uri);
    } else {
      return null;
    }
  }
}
