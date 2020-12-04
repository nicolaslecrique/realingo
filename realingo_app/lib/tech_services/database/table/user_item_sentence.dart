import 'package:json_annotation/json_annotation.dart';

import '../schema.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
part 'user_item_sentence.g.dart';

class TableUserItemSentence {
  final String id = 'id';
  final String uri = 'uri';
  final String sentence = 'sentence';
  final String translation = 'translation';
  final String itemSentenceServerUri = 'item_sentence_server_uri';
  final String userItemToLearnId = 'user_item_to_learn_id';

  const TableUserItemSentence();

  @override
  String toString() {
    return 'user_item_sentence';
  }

  String getCreateQuery() => '''
  CREATE TABLE $this(
    $id INTEGER PRIMARY KEY,
    $uri TEXT NOT NULL UNIQUE,
    $sentence TEXT NOT NULL,
    $translation TEXT NOT NULL,
    $itemSentenceServerUri STRING NOT NULL,
    $userItemToLearnId INTEGER NOT NULL,
    FOREIGN KEY ($userItemToLearnId) REFERENCES ${DB.userItemToLearn}(${DB.userItemToLearn.id})
  )
  ''';

  String getSelectQueryFromProgram(int programId) => '''
  SELECT
    $this.*
   FROM
    $this
   INNER JOIN ${DB.userItemToLearn} ON ${DB.userItemToLearn}.${DB.userItemToLearn.id} = $userItemToLearnId
   INNER JOIN ${DB.userLearningProgram} ON ${DB.userLearningProgram}.${DB.userLearningProgram.id} = ${DB.userItemToLearn}.${DB.userItemToLearn.userLearningProgramId}
   WHERE ${DB.userLearningProgram}.${DB.userLearningProgram.id} = $programId
 
  ''';
}

@JsonSerializable(createToJson: false)
class RowUserItemSentence {
  final int id;
  final String uri;
  final String sentence;
  final String translation;

  @JsonKey(name: 'item_sentence_server_uri')
  final String itemSentenceServerUri;
  @JsonKey(name: 'user_item_to_learn_id')
  final int userItemToLearnId;

  RowUserItemSentence(
      this.id, this.uri, this.sentence, this.translation, this.itemSentenceServerUri, this.userItemToLearnId);

  factory RowUserItemSentence.fromDb(Map<String, dynamic> json) => _$RowUserItemSentenceFromJson(json);
}
