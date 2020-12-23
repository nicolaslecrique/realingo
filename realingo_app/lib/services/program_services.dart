import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
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

  static Future<LearningProgram> getProgram(Language learnedLanguage, Language originLanguage) async {
    return await RestApi.getProgram(learnedLanguage, originLanguage);
  }

  static Future<UserLearningProgram> buildUserProgram(LearningProgram program, ItemToLearn firstItemToLearn) async {
    final now = DateTime.now().toString();

    String userProgramUri = '${program.uri}-$now';

    List<UserItemToLearn> userItems = <UserItemToLearn>[];
    UserItemToLearnStatus status = UserItemToLearnStatus.SkippedAtStart;
    for (int i = 0; i < program.itemsToLearn.length; i++) {
      ItemToLearn current = program.itemsToLearn[i];
      if (current == firstItemToLearn) {
        status = UserItemToLearnStatus.NotLearned;
      }
      userItems.add(UserItemToLearn(
          '${current.uri}-$userProgramUri',
          current.uri,
          current.label,
          current.sentences
              .map((s) => UserItemToLearnSentence(s.uri, '${s.uri}-$userProgramUri', s.sentence, s.translation, s.hint))
              .toList(),
          status));
    }

    final userProgram =
        UserLearningProgram(userProgramUri, program.uri, userItems, program.learnedLanguage, program.originLanguage);
    await db.insertUserLearningProgram(userProgram);
    await UserConfig.setDefaultUserProgramUri(userProgram.uri);
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
