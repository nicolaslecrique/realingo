import 'package:json_annotation/json_annotation.dart';

import '../schema.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
part 'user_program.g.dart';

class TableUserProgram {
  final String id = "id";
  final String uri = "uri";
  final String learningProgramId = "learning_program_id";

  @override
  String toString() {
    return "user_program";
  }

  String getCreateQuery() => '''
  CREATE TABLE $this(
    $id INTEGER PRIMARY KEY,
    $uri TEXT NOT NULL UNIQUE,
    $learningProgramId INTEGER NOT NULL,
    FOREIGN KEY ($learningProgramId) REFERENCES  ${DB.learningProgram}(${DB.learningProgram.id})
  )
  ''';
}

@JsonSerializable(createToJson: false)
class RowUserProgram {
  final int id;
  final String uri;
  @JsonKey(name: "learning_program_id")
  final int learningProgramId;

  RowUserProgram(this.id, this.uri, this.learningProgramId);

  factory RowUserProgram.fromDb(Map<String, dynamic> json) => _$RowUserProgramFromJson(json);
}
