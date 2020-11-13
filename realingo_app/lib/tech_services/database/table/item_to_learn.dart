import 'package:json_annotation/json_annotation.dart';

import '../schema.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build

part 'item_to_learn.g.dart';

class TableItemToLearn {
  final String id = "id";
  final String uri = "uri";
  final String label = "label";
  final String idxInProgram = "idx_in_program";
  final String learningProgramId = "learning_program_id";

  @override
  String toString() {
    return "item_to_learn";
  }

  String getCreateQuery() => '''
  CREATE TABLE $this(
    $id INTEGER PRIMARY_KEY,
    $uri TEXT NOT NULL UNIQUE,
    $label TEXT NOT NULL,
    $idxInProgram INTEGER NOT NULL,
    $learningProgramId INTEGER NOT NULL,
    FOREIGN KEY ($learningProgramId) REFERENCES ${DB.learningProgram.id}
  )
  ''';
}

@JsonSerializable(createToJson: false)
class RowItemToLean {
  final int id;
  final String uri;
  final String label;
  @JsonKey(name: "idx_in_program")
  final int idxInProgram;
  @JsonKey(name: "learning_program_id")
  final int learningProgramId;

  RowItemToLean(this.id, this.uri, this.label, this.idxInProgram, this.learningProgramId);

  factory RowItemToLean.fromDb(Map<String, dynamic> json) => _$RowItemToLeanFromJson(json);
}
