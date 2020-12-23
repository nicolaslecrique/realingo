import 'package:json_annotation/json_annotation.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
part 'user_learning_program.g.dart';

class TableUserLearningProgram {
  final String id = 'id';
  final String uri = 'uri';
  final String learningProgramServerUri = 'learning_program_server_uri';
  final String learnedLanguageUri = 'learned_language_uri';
  final String originLanguageUri = 'origin_language_uri';

  @override
  String toString() {
    return 'user_learning_program';
  }

  const TableUserLearningProgram();

  String getCreateQuery() => '''
  CREATE TABLE $this(
    $id INTEGER PRIMARY KEY,
    $uri TEXT NOT NULL UNIQUE,
    $learningProgramServerUri TEXT NOT NULL,
    $learnedLanguageUri TEXT NOT NULL,
    $originLanguageUri TEXT NOT NULL
  )
  ''';
}

@JsonSerializable(createToJson: false)
class RowUserLearningProgram {
  final int id;
  final String uri;
  @JsonKey(name: 'learning_program_server_uri')
  final String learningProgramServerUri;

  @JsonKey(name: 'learned_language_uri')
  final String learnedLanguageUri;

  @JsonKey(name: 'origin_language_uri')
  final String originLanguageUri;

  RowUserLearningProgram(
      this.id, this.uri, this.learningProgramServerUri, this.learnedLanguageUri, this.originLanguageUri);

  factory RowUserLearningProgram.fromDb(Map<String, dynamic> json) => _$RowUserLearningProgramFromJson(json);
}
