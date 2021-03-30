import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/services/texttospeech_service.dart';
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

      final userProgram = Result.mergeWrap<UserLearningProgram, LearningProgram, String>(
          program, programState.nextLessonUri, (p, l) => UserLearningProgram(p, programState.nextLessonUri));

      return userProgram;
    } else {
      return null;
    }
  }

  static Future<Result<Lesson>> getLesson(LearningProgram program, String lessonUri) async {
    Result<Lesson> lesson = await RestApi.getLesson(program.uri, lessonUri);
    if (lesson.isOk) {
      final Result<void> resultRecords = await TextToSpeech.loadSentences(program.learnedLanguageUri,
          List<Sentence>.unmodifiable(lesson.result.exercises.map<Sentence>((e) => e.sentence)));
      return Result.merge<Lesson, Lesson, void>(lesson, resultRecords, (l, r) => l);
    }
    return lesson;
  }

  static Future<void> setDefaultUserProgram(LearningProgram program) async {
    await UserConfig.setDefaultProgram(program.uri);
    return await UserConfig.setNextLessonUri(program.uri, program.lessons.first.uri);
  }

  static Future<String> setCompletedLessonReturnNext(LearningProgram program, String completedLessonUri) async {
    final String previousNextLessonUri = (await UserConfig.getDefaultProgramStateOrNull())!.nextLessonUri;
    if (previousNextLessonUri != completedLessonUri) {
      // nothing to do
      return previousNextLessonUri;
    }

    int completedLessonIdx = program.lessons.indexWhere((e) => e.uri == completedLessonUri);
    int nextLessonIdx = completedLessonIdx == program.lessons.length - 1 ? completedLessonIdx : completedLessonIdx + 1;
    String nextLessonUri = program.lessons[nextLessonIdx].uri;

    await UserConfig.setNextLessonUri(program.uri, nextLessonUri);
    return nextLessonUri;
  }
}
