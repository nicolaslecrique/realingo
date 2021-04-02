import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/tech_services/analytics.dart';
import 'package:realingo_app/tech_services/result.dart';

enum UserProgramModelStatus { NoDefaultProgram, LoadingFailed, Loaded }

class UserProgramModel extends ChangeNotifier {
  Result<UserLearningProgram>? _programOrNull;

  Future<void> loadDefaultProgram() async {
    _programOrNull = await ProgramServices.getDefaultUserProgramOrNull();
    if (_programOrNull != null && _programOrNull!.isOk) {
      Analytics.setDefaultProgram(_programOrNull!.result);
    }
    notifyListeners();
  }

  Future<void> setUserProgramNextLesson(String completedLessonUri) async {
    String nextLessonUri = await ProgramServices.setCompletedLessonReturnNext(userProgram.program, completedLessonUri);
    _programOrNull = Result.ok(UserLearningProgram(userProgram.program, nextLessonUri));
    Analytics.setDefaultProgram(_programOrNull!.result);
    notifyListeners();
  }

  // should not be called if status != Loaded
  UserLearningProgram get userProgram => _programOrNull!.result;

  UserProgramModelStatus get status => _programOrNull == null
      ? UserProgramModelStatus.NoDefaultProgram
      : _programOrNull!.isOk
          ? UserProgramModelStatus.Loaded
          : UserProgramModelStatus.LoadingFailed;
}
