import 'package:json_annotation/json_annotation.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
part 'user_learning_program.g.dart';

class TableUserLearningProgram {
  final String id = 'id';
  final String uri = 'uri';
  final String learningProgramServerUri = 'learning_program_server_uri';

  @override
  String toString() {
    return 'user_learning_program';
  }

  const TableUserLearningProgram();

  String getCreateQuery() => '''
  CREATE TABLE $this(
    $id INTEGER PRIMARY KEY,
    $uri TEXT NOT NULL UNIQUE,
    $learningProgramServerUri TEXT NOT NULL
  )
  ''';
}

@JsonSerializable(createToJson: false)
class RowUserLearningProgram {
  final int id;
  final String uri;
  @JsonKey(name: 'learning_program_server_uri')
  final String learningProgramServerUri;

  RowUserLearningProgram(this.id, this.uri, this.learningProgramServerUri);

  factory RowUserLearningProgram.fromDb(Map<String, dynamic> json) => _$RowUserLearningProgramFromJson(json);
}
