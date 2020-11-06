import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DbItemToLearn {
  final String uri;
  final String itemLabel;

  DbItemToLearn(this.uri, this.itemLabel);
}

class DbLearningProgram {
  final String uri;
  final List<DbItemToLearn> itemsToLearn;

  DbLearningProgram(this.uri, this.itemsToLearn);
}

class DbUserProgram {
  final String uri;
  final String learningProgramUri;

  DbUserProgram(this.uri, this.learningProgramUri);
}

/*
Access to data in hive database
 */
class Db {
  static final String _boxGlobalVariablesKey = "global_variables";
  static final String _boxUserProgramsKey = "userPrograms";
  static final String _boxLearningProgramsKey = "learningPrograms";

  static Future<void> load() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxGlobalVariablesKey);
    await Hive.openBox(_boxUserProgramsKey);
    await Hive.openBox(_boxLearningProgramsKey);
  }

  static close() {
    Hive.close();
  }

  static Box<String> _boxGlobalVariables() {
    return Hive.box<String>(_boxGlobalVariablesKey);
  }

  static Box<DbUserProgram> _boxUserPrograms() {
    return Hive.box<DbUserProgram>(_boxUserProgramsKey);
  }

  static Box<DbLearningProgram> _boxLearningPrograms() {
    return Hive.box<DbLearningProgram>(_boxLearningProgramsKey);
  }

  static String getCurrentUserProgramUriOrNull() {
    return _boxGlobalVariables().get("current_user_program_uri");
  }

  static DbUserProgram getUserProgram(String userProgramUri) {
    return _boxUserPrograms().get(userProgramUri);
  }

  static Future<void> saveLearningProgram(DbLearningProgram program) async {
    _boxLearningPrograms().put(program.uri, program);
  }

  static Future<void> saveUserProgram(DbUserProgram userProgram) async {
    _boxUserPrograms().put(userProgram.uri, userProgram);
  }
}
