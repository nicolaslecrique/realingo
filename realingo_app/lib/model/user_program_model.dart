import 'package:flutter/foundation.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/services/program_services.dart';

class UserProgramModel extends ChangeNotifier {
  UserLearningProgram _programOrNull;

  Future<void> reload() async {
    _programOrNull = await ProgramServices.getDefaultUserProgramOrNull();
    notifyListeners();
  }

  UserLearningProgram get program => _programOrNull;
}
