import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DbUserProgram {
  final String uri;

  DbUserProgram(this.uri);
}

class DbLoader {
  static String _boxGlobalVariables = "global_variables";
  static String _boxUserPrograms = "userPrograms";

  static Future<Db> load() async {
    await Hive.initFlutter();
    Box<String> globalVariablesBox = await Hive.openBox(_boxGlobalVariables);
    Box<DbUserProgram> userProgramsBox = await Hive.openBox(_boxUserPrograms);
    return Db(globalVariablesBox, userProgramsBox);
  }
}

/*
Access to data in hive database
 */
class Db {
  final Box<String> _globalVariablesBox;
  final Box<DbUserProgram> _userProgramsBox;

  Db(this._globalVariablesBox, this._userProgramsBox);

  String getCurrentUserProgramUriOrNull() {
    return _globalVariablesBox.get("current_user_program_uri");
  }

  DbUserProgram getUserProgram(String userProgramUri) {
    return _userProgramsBox.get(userProgramUri);
  }
}
