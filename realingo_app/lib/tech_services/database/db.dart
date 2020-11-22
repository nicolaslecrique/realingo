import 'dart:async';

import 'package:collection/collection.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/tech_services/database/db_init.dart';
import 'package:realingo_app/tech_services/database/schema.dart';
import 'package:realingo_app/tech_services/database/table/user_item_sentence.dart';
import 'package:realingo_app/tech_services/database/table/user_item_to_learn.dart';
import 'package:realingo_app/tech_services/database/table/user_learning_program.dart';
import 'package:sqflite/sqflite.dart';

final db = Db();

class Db {
  Database _db;

  Future<void> init() async {
    String path = await dbPath;
    return await initWith(databaseFactory, path);
  }

  Future<void> initWith(DatabaseFactory databaseFactory, String dbPath) async {
    _db = await initDb(databaseFactory, dbPath);
    return;
  }

  UserItemToLearnStatus _userItemToLearnStatusFromDbString(String dbString) {
    switch (dbString) {
      case "NotLearned":
        return UserItemToLearnStatus.NotLearned;
      case "KnownAtStart":
        return UserItemToLearnStatus.KnownAtStart;
      default:
        throw Exception("$dbString cannot be converted to UserItemToLearnStatus");
    }
  }

  String _userItemToLearnStatusToDbString(UserItemToLearnStatus status) {
    switch (status) {
      case UserItemToLearnStatus.NotLearned:
        return "NotLearned";
      case UserItemToLearnStatus.KnownAtStart:
        return "KnownAtStart";
      default:
        throw Exception("$status cannot be converted from UserItemToLearnStatus to string");
    }
  }

  Future<void> insertUserLearningProgram(UserLearningProgram userProgram) async {
    return await _db.transaction((Transaction txn) async {
      int idProgram = await txn.insert("${DB.userLearningProgram}", {
        DB.userLearningProgram.uri: userProgram.uri,
        DB.userLearningProgram.learningProgramServerUri: userProgram.serverUri,
      });

      for (int idxItem = 0; idxItem < userProgram.itemsToLearn.length; idxItem++) {
        UserItemToLearn item = userProgram.itemsToLearn[idxItem];

        int idItemDb = await txn.insert("${DB.userItemToLearn}", {
          DB.userItemToLearn.uri: item.uri,
          DB.userItemToLearn.label: item.label,
          DB.userItemToLearn.idxInProgram: idxItem,
          DB.userItemToLearn.status: _userItemToLearnStatusToDbString(item.status),
          DB.userItemToLearn.itemToLearnServerUri: item.serverUri,
          DB.userItemToLearn.userLearningProgramId: idProgram,
        });

        Batch batch = txn.batch();
        for (UserItemToLearnSentence sentence in item.sentences) {
          batch.insert("${DB.userItemSentence}", {
            DB.userItemSentence.uri: sentence.uri,
            DB.userItemSentence.sentence: sentence.sentence,
            DB.userItemSentence.translation: sentence.translation,
            DB.userItemSentence.itemSentenceServerUri: sentence.serverUri,
            DB.userItemSentence.userItemToLearnId: idItemDb,
          });
        }
        batch.commit();
      }
    });
  }

  Future<UserLearningProgram> getUserLearningProgram(String uri) async {
    List<Map<String, dynamic>> resultUserProgram =
        await _db.query("${DB.userLearningProgram}", where: '${DB.userLearningProgram.uri} = ?', whereArgs: [uri]);

    RowUserLearningProgram userProgram = RowUserLearningProgram.fromDb(resultUserProgram[0]);

    final List<Map<String, dynamic>> resultItems = await _db.query("${DB.userItemToLearn}",
        where: '${DB.userItemToLearn.userLearningProgramId} = ?',
        whereArgs: [userProgram.id],
        orderBy: DB.userItemToLearn.idxInProgram);

    final List<Map<String, dynamic>> resultSentences =
        await _db.rawQuery(DB.userItemSentence.getSelectQueryFromProgram(userProgram.id));

    final List<RowUserItemSentence> sentences = resultSentences.map((e) => RowUserItemSentence.fromDb(e)).toList();

    Map<int, List<RowUserItemSentence>> sentencesByItemId =
        groupBy(sentences, (RowUserItemSentence s) => s.userItemToLearnId);

    List<UserItemToLearn> items = resultItems
        .map((e) => RowUserItemToLearn.fromDb(e))
        .map((e) => UserItemToLearn(
            e.uri,
            e.itemToLearnServerUri,
            e.label,
            sentencesByItemId[e.id]
                .map((s) => UserItemToLearnSentence(s.uri, s.itemSentenceServerUri, s.sentence, s.translation))
                .toList(),
            _userItemToLearnStatusFromDbString(e.status)))
        .toList();

    return UserLearningProgram(userProgram.uri, userProgram.learningProgramServerUri, items);
  }
}
