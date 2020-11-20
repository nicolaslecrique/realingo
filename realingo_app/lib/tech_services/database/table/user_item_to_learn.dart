import 'package:json_annotation/json_annotation.dart';

import '../schema.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
part 'user_item_to_learn.g.dart';

class TableUserItemToLearn {
  final String id = "id";
  final String uri = "uri";
  final String label = "label";
  final String idxInProgram = "idx_in_program";
  final String status = "status";
  final String itemToLearnServerUri = "item_to_learn_server_uri";
  final String userLearningProgramId = "user_learning_program_id";

  @override
  String toString() {
    return "user_item_to_learn";
  }

  String getCreateQuery() => '''
  CREATE TABLE $this(
    $id INTEGER PRIMARY KEY,
    $uri TEXT NOT NULL UNIQUE,
    $label TEXT NOT NULL,
    $idxInProgram INTEGER NOT NULL,
    $status TEXT NOT NULL,
    $itemToLearnServerUri STRING NOT NULL,
    $userLearningProgramId INTEGER NOT NULL,
    FOREIGN KEY ($userLearningProgramId) REFERENCES ${DB.userLearningProgram}(${DB.userLearningProgram.id})
  )
  ''';
}

@JsonSerializable(createToJson: false)
class RowUserItemToLearn {
  final int id;
  final String uri;
  final String label;
  @JsonKey(name: "idx_in_program")
  final int idxInProgram;
  final String status;

  @JsonKey(name: "item_to_learn_server_uri")
  final String itemToLearnServerUri;

  @JsonKey(name: "user_learning_program_id")
  final int userLearningProgramId;

  RowUserItemToLearn(this.id, this.uri, this.label, this.idxInProgram, this.status, this.itemToLearnServerUri,
      this.userLearningProgramId);

  factory RowUserItemToLearn.fromDb(Map<String, dynamic> json) => _$RowUserItemToLearnFromJson(json);
}
