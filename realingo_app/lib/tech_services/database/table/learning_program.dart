import 'package:json_annotation/json_annotation.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
part 'learning_program.g.dart';

class TableLearningProgram {
  final String id = "id";
  final String uri = "uri";

  @override
  String toString() {
    return "learning_program";
  }

  String getCreateQuery() => '''
  CREATE TABLE $this(
    $id INTEGER PRIMARY KEY,
    $uri TEXT NOT NULL UNIQUE
  )
  ''';
}

@JsonSerializable(createToJson: false)
class RowLearningProgram {
  final int id;
  final String uri;

  RowLearningProgram(this.id, this.uri);

  factory RowLearningProgram.fromDb(Map<String, dynamic> json) => _$RowLearningProgramFromJson(json);
}
