import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/tech_services/result.dart';

class UserProgramModel extends ChangeNotifier {
  UserLearningProgram? _programOrNull;

  Future<void> loadDefaultProgram() async {
    final Result<UserLearningProgram>? programResult = await ProgramServices.getDefaultUserProgramOrNull();
    _programOrNull = programResult == null ? null : programResult.result; // TODO ICI MANAGE ERROR CASE
    notifyListeners();
  }

  Future<void> setUserProgramNextLesson(String completedLessonUri) async {
    String nextLessonUri =
        await ProgramServices.setCompletedLessonReturnNext(_programOrNull!.program, completedLessonUri);
    _programOrNull = UserLearningProgram(_programOrNull!.program, nextLessonUri);
    notifyListeners();
  }

  UserLearningProgram? get programOrNull => _programOrNull;
}
