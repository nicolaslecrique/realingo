import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/tech_services/rest/rest_api.dart';
import 'package:realingo_app/tech_services/result.dart';
import 'package:realingo_app/tech_services/user_config.dart';

class ProgramServices {
  static Future<Result<List<Language>>> getAvailableTargetLanguages() async {
    return await RestApi.getAvailableLearnedLanguages();
  }

  static Future<Result<List<Language>>> getAvailableOriginLanguages(Language learnedLanguage) async {
    return await RestApi.getAvailableOriginLanguages(learnedLanguage.uri);
  }

  static Future<Result<LearningProgram>> getProgram(Language learnedLanguage, Language originLanguage) async {
    return await RestApi.getProgramByLanguage(learnedLanguage, originLanguage);
  }

  static Future<Result<UserLearningProgram>?> getDefaultUserProgramOrNull() async {
    ProgramState? programState = await UserConfig.getDefaultProgramStateOrNull();
    if (programState != null) {
      Result<LearningProgram> program = await RestApi.getProgram(programState.programUri);
      Result<Lesson> nextLesson = await RestApi.getLesson(programState.programUri, programState.nextLessonUri);

      final userProgram = Result.merge<UserLearningProgram, LearningProgram, Lesson>(
          program, nextLesson, (p, l) => UserLearningProgram(p, l));

      return userProgram;
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
