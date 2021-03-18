import 'package:realingo_app/tech_services/user_config.dart';

class LessonSaver {
  static Future<void> saveCompletedLesson(String programUri, String lessonUri) async {
    await UserConfig.setLastCompletedLessonUri(programUri, lessonUri);
  }
}
