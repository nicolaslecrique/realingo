import 'dart:async';

import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/database/db_init.dart';
import 'package:realingo_app/tech_services/database/schema.dart';
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
        DB.userLearningProgram.learningProgramServerUri: userProgram.learningProgramServerUri,
      });

      Batch batch = txn.batch();
      for (int idItem = 0; idItem < userProgram.itemsToLearn.length; idItem++) {
        UserItemToLearn item = userProgram.itemsToLearn[idItem];

        batch.insert("${DB.userItemToLearn}", {
          DB.userItemToLearn.uri: item.uri,
          DB.userItemToLearn.label: item.itemToLearn.label,
          DB.userItemToLearn.idxInProgram: idItem,
          DB.userItemToLearn.status: _userItemToLearnStatusToDbString(item.status),
          DB.userItemToLearn.itemToLearnServerUri: item.itemToLearn.uri,
          DB.userItemToLearn.userLearningProgramId: idProgram,
        });
      }
      batch.commit();
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

    List<UserItemToLearn> items = resultItems
        .map((e) => RowUserItemToLearn.fromDb(e))
        .map((e) => UserItemToLearn(
            e.uri, ItemToLearn(e.itemToLearnServerUri, e.label), _userItemToLearnStatusFromDbString(e.status)))
        .toList();

    return UserLearningProgram(userProgram.uri, userProgram.learningProgramServerUri, items);
  }
}
