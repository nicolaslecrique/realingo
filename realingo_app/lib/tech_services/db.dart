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

class _GlobalVariableBoxKeys {
  static final String currentUserProgramUri = "current_user_program_uri";
}

// associate boxName, type of data and typeAdapters
class _Box<T> {
  final String _name;
  final List<TypeAdapter> _adapters;

  _Box(this._name, this._adapters);

  T get(String key) {
    return Hive.box<T>(_name).get(key);
  }

  Future<void> put(String key, T value) async {
    return await Hive.box<T>(_name).put(key, value);
  }

  void register() {
    _adapters.forEach((element) {
      Hive.registerAdapter(element);
    });
  }

  Future<void> open() async {
    return await Hive.openBox<T>(_name);
  }

  Future<void> delete() async {
    return (await Hive.openBox<T>(_name)).deleteFromDisk();
  }
}

/*
Access to data in hive database
 */
class Db {
  static _Box<dynamic> globalVariables = _Box("global_variables", []);
  static _Box<DbUserProgram> userPrograms = _Box("user_programs", [DbUserProgramAdapter()]);
  static _Box<DbLearningProgram> learningPrograms =
      _Box("learning_programs", [DbLearningProgramAdapter(), DbItemToLearnAdapter()]);

  static final all = [globalVariables, userPrograms, learningPrograms];

  static Future<void> load() async {
    await Hive.initFlutter();

    for (_Box box in all) {
      box.register();
    }

    if (AppConfig.deleteHiveData == "TRUE") {
      for (_Box box in all) {
        await box.delete();
      }
    }

    for (_Box box in all) {
      await box.open();
    }
  }

  static close() {
    Hive.close();
  }

  static String getCurrentUserProgramUriOrNull() {
    return globalVariables.get(_GlobalVariableBoxKeys.currentUserProgramUri);
  }

  static Future<void> setCurrentUserProgramUri(String userProgramUri) async {
    return globalVariables.put(_GlobalVariableBoxKeys.currentUserProgramUri, userProgramUri);
  }

  static DbUserProgram getUserProgram(String userProgramUri) {
    return userPrograms.get(userProgramUri);
  }

  static Future<void> setUserProgram(DbUserProgram userProgram) async {
    return userPrograms.put(userProgram.uri, userProgram);
  }

  static DbLearningProgram getLearningProgram(String uri) {
    return learningPrograms.get(uri);
  }

  static Future<void> setLearningProgram(DbLearningProgram program) async {
    return learningPrograms.put(program.uri, program);
  }
}
