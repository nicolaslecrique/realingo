import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
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
    return await RestApi.getProgramByLanguage(learnedLanguage, originLanguage);
  }

  static Future<UserLearningProgram> getDefaultUserProgramOrNull() async {
    ProgramState programState = await UserConfig.getDefaultProgramStateOrNull();
    if (programState != null) {
      LearningProgram program = await RestApi.getProgram(programState.programUri);
      Lesson nextLesson = await RestApi.getLesson(programState.programUri, programState.nextLessonUri);
      return UserLearningProgram(program, nextLesson);
    } else {
      return null;
    }
  }

  static Future<void> setDefaultUserProgram(LearningProgram program) async {
    await UserConfig.setDefaultProgram(program.uri);
    return await UserConfig.setNextLessonUri(program.uri, program.lessons.first.uri);
  }

  static Future<void> setUserProgramNextLesson(LearningProgram program, String completedLessonUri) async {
    int lastLessonIdx = program.lessons.indexWhere((e) => e.uri == completedLessonUri);
    int nextLessonIdx = lastLessonIdx == program.lessons.length - 1 ? lastLessonIdx : lastLessonIdx + 1;
    String nextLessonUri = program.lessons[nextLessonIdx].uri;

    return await UserConfig.setNextLessonUri(program.uri, nextLessonUri);
  }
}
