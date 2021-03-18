import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class ProgramState {
  final String programUri;
  final String nextLessonUri;

  const ProgramState(this.programUri, this.nextLessonUri);
}

class UserConfig {
  static const String _defaultProgramUriKey = 'default_program_uri';
  static String _getNextLessonUriKey(String programUri) => '${programUri}/next_lesson_uri';

  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<ProgramState> getDefaultProgramStateOrNull() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_defaultProgramUriKey)) {
      return null;
    }

    String programUri = prefs.getString(_defaultProgramUriKey);
    String lessonKey = _getNextLessonUriKey(programUri);
    if (!prefs.containsKey(lessonKey)) {
      String lessonUri = prefs.getString(lessonKey);
      return ProgramState(programUri, lessonUri);
    } else {
      return ProgramState(programUri, null);
    }
  }

  static Future<void> setDefaultProgram(String programUri) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultProgramUriKey, programUri);
  }

  static Future<void> setNextLessonUri(String programUri, String lessonUri) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lessonKey = _getNextLessonUriKey(programUri);
    await prefs.setString(lessonKey, lessonUri);
  }
}
