import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realingo_app/tech_services/app_config.dart';

// command line to generate the TypeAdaptater for objects put in hive
// ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
// flutter packages pub run build_runner build
part 'db.g.dart';

@HiveType(typeId: 0)
class DbItemToLearn {
  @HiveField(0)
  final String uri;

  @HiveField(1)
  final String itemLabel;

  DbItemToLearn(this.uri, this.itemLabel);
}

@HiveType(typeId: 1)
class DbLearningProgram {
  @HiveField(0)
  final String uri;

  @HiveField(1)
  final List<DbItemToLearn> itemsToLearn;

  DbLearningProgram(this.uri, this.itemsToLearn);
}

@HiveType(typeId: 2)
class DbUserProgram {
  @HiveField(0)
  final String uri;

  @HiveField(1)
  final String learningProgramUri;

  DbUserProgram(this.uri, this.learningProgramUri);
}

/*
Access to data in hive database
 */
class Db {
  static final String _boxGlobalVariablesKey = "global_variables";
  static final String _boxUserProgramsKey = "user_programs";
  static final String _boxLearningProgramsKey = "learning_programs";

  static Future<void> load() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DbItemToLearnAdapter());
    Hive.registerAdapter(DbLearningProgramAdapter());
    Hive.registerAdapter(DbUserProgramAdapter());

    if (AppConfig.deleteHiveData == "TRUE") {
      (await Hive.openBox<dynamic>(_boxGlobalVariablesKey)).deleteFromDisk();
      (await Hive.openBox<dynamic>(_boxUserProgramsKey)).deleteFromDisk();
      (await Hive.openBox<dynamic>(_boxLearningProgramsKey)).deleteFromDisk();
    }

    await Hive.openBox<dynamic>(_boxGlobalVariablesKey);
    await Hive.openBox<DbUserProgram>(_boxUserProgramsKey);
    await Hive.openBox<DbLearningProgram>(_boxLearningProgramsKey);
  }

  static Box<dynamic> _boxGlobalVariables() {
    return Hive.box<dynamic>(_boxGlobalVariablesKey);
  }

  static Box<DbUserProgram> _boxUserPrograms() {
    return Hive.box<DbUserProgram>(_boxUserProgramsKey);
  }

  static Box<DbLearningProgram> _boxLearningPrograms() {
    return Hive.box<DbLearningProgram>(_boxLearningProgramsKey);
  }

  static close() {
    Hive.close();
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
