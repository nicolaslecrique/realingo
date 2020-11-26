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

class UserItemToLearnStatusDb {
  static const String NotLearned = "NotLearned";
  static const String SkippedAtStart = "SkippedAtStart";
  static const String Skipped = "Skipped";
  static const String Learned = "Learned";

  static UserItemToLearnStatus fromDbString(String dbString) {
    switch (dbString) {
      case NotLearned:
        return UserItemToLearnStatus.NotLearned;
      case SkippedAtStart:
        return UserItemToLearnStatus.SkippedAtStart;
      case Skipped:
        return UserItemToLearnStatus.Skipped;
      case Learned:
        return UserItemToLearnStatus.Learned;
      default:
        throw Exception("$dbString cannot be converted to UserItemToLearnStatus");
    }
  }

  static String toDbString(UserItemToLearnStatus status) {
    switch (status) {
      case UserItemToLearnStatus.NotLearned:
        return NotLearned;
      case UserItemToLearnStatus.SkippedAtStart:
        return SkippedAtStart;
      case UserItemToLearnStatus.Skipped:
        return Skipped;
      case UserItemToLearnStatus.Learned:
        return Learned;
      default:
        throw Exception("$status cannot be converted from UserItemToLearnStatus to string");
    }
  }
}

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

  Future<void> insertUserLearningProgram(UserLearningProgram userProgram) async {
    return await _db.transaction((Transaction txn) async {
      int idProgram = await txn.insert("${DB.userLearningProgram}", {
        DB.userLearningProgram.uri: userProgram.uri,
        DB.userLearningProgram.learningProgramServerUri: userProgram.serverUri,
      });

      Batch batchItems = txn.batch();

      for (int idxItem = 0; idxItem < userProgram.itemsToLearn.length; idxItem++) {
        UserItemToLearn item = userProgram.itemsToLearn[idxItem];

        batchItems.insert("${DB.userItemToLearn}", {
          DB.userItemToLearn.uri: item.uri,
          DB.userItemToLearn.label: item.label,
          DB.userItemToLearn.idxInProgram: idxItem,
          DB.userItemToLearn.status: UserItemToLearnStatusDb.toDbString(item.status),
          DB.userItemToLearn.itemToLearnServerUri: item.serverUri,
          DB.userItemToLearn.userLearningProgramId: idProgram,
        });
      }
      // itemIds is not a list<int> be behaves like it is
      final itemIds = await batchItems.commit();

      Batch batchSentence = txn.batch();

      for (int idxItem = 0; idxItem < userProgram.itemsToLearn.length; idxItem++) {
        UserItemToLearn item = userProgram.itemsToLearn[idxItem];

        for (UserItemToLearnSentence sentence in item.sentences) {
          batchSentence.insert("${DB.userItemSentence}", {
            DB.userItemSentence.uri: sentence.uri,
            DB.userItemSentence.sentence: sentence.sentence,
            DB.userItemSentence.translation: sentence.translation,
            DB.userItemSentence.itemSentenceServerUri: sentence.serverUri,
            DB.userItemSentence.userItemToLearnId: itemIds[idxItem],
          });
        }
      }
      await batchSentence.commit(noResult: true);
    });
  }

  Future<UserLearningProgram> getUserLearningProgram(String uri) async {
    List<Map<String, dynamic>> resultUserProgram =
        await _db.query("${DB.userLearningProgram}", where: '${DB.userLearningProgram.uri} = ?', whereArgs: [uri]);

    RowUserLearningProgram userProgram = RowUserLearningProgram.fromDb(resultUserProgram[0]);

    List<RowUserItemToLearn> rowItems = await _selectRowItemsFromProgramIdx(userProgram.id);

    final List<Map<String, dynamic>> resultSentences =
        await _db.rawQuery(DB.userItemSentence.getSelectQueryFromProgram(userProgram.id));

    final List<RowUserItemSentence> sentences = resultSentences.map((e) => RowUserItemSentence.fromDb(e)).toList();

    Map<int, List<RowUserItemSentence>> sentencesByItemId =
        groupBy(sentences, (RowUserItemSentence s) => s.userItemToLearnId);

    List<UserItemToLearn> items = rowItems
        .map((e) => UserItemToLearn(
            e.uri,
            e.itemToLearnServerUri,
            e.label,
            sentencesByItemId[e.id]
                .map((s) => UserItemToLearnSentence(s.uri, s.itemSentenceServerUri, s.sentence, s.translation))
                .toList(),
            UserItemToLearnStatusDb.fromDbString(e.status)))
        .toList();

    return UserLearningProgram(userProgram.uri, userProgram.learningProgramServerUri, items);
  }

  Future<List<RowUserItemToLearn>> _selectRowItemsFromProgramIdx(int idProgram) async {
    final List<Map<String, dynamic>> resultItems = await _db.query("${DB.userItemToLearn}",
        where: '${DB.userItemToLearn.userLearningProgramId} = ?',
        whereArgs: [idProgram],
        orderBy: DB.userItemToLearn.idxInProgram);

    final List<RowUserItemToLearn> rowItems = resultItems.map((e) => RowUserItemToLearn.fromDb(e)).toList();
    return rowItems;
  }
}
