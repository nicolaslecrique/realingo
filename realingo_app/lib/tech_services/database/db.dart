import 'dart:async';

import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/database/db_init.dart';
import 'package:realingo_app/tech_services/database/schema.dart';
import 'package:realingo_app/tech_services/database/table/item_to_learn.dart';
import 'package:realingo_app/tech_services/database/table/learning_program.dart';
import 'package:realingo_app/tech_services/database/table/user_program.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static Database _db;

  static Future<void> init() async {
    _db = await initDb();
    return;
  }

  static Future<void> insertUserProgram(UserProgram userProgram) async {
    LearningProgram program = userProgram.program;

    return await _db.transaction((Transaction txn) async {
      // 1) insert program id needed
      var idProgram = Sqflite.firstIntValue(
          await txn.rawQuery("SELECT id FROM ${DB.learningProgram} WHERE uri = ?", [program.uri]));
      if (idProgram == null) {
        idProgram = await txn.insert("${DB.learningProgram}", {DB.learningProgram.uri: program.uri});
        Batch batch = txn.batch();
        for (int idItem = 0; idItem < program.itemsToLearn.length; idItem++) {
          ItemToLearn item = program.itemsToLearn[idItem];

          batch.insert("${DB.itemToLearn}", {
            DB.itemToLearn.uri: item.uri,
            DB.itemToLearn.idxInProgram: idItem,
            DB.itemToLearn.label: item.label,
            DB.itemToLearn.learningProgramId: idProgram,
            DB.itemToLearn.uri: item.uri,
          });
        }
      }
      // 2) insert userProgram
      txn.insert(
          "${DB.userProgram}", {DB.userProgram.uri: userProgram.uri, DB.userProgram.learningProgramId: idProgram});
    });
  }

  static Future<LearningProgram> getLearningProgram(String uri) async {
    List<Map<String, dynamic>> resultProgram =
        await _db.query("${DB.learningProgram}", where: '${DB.learningProgram.uri} = ?', whereArgs: [uri]);
    RowLearningProgram learningProgram = RowLearningProgram.fromDb(resultProgram[0]);

    final List<Map<String, dynamic>> resultItems = await _db.query("${DB.itemToLearn}",
        where: '${DB.itemToLearn.id} = ?', whereArgs: [learningProgram.id], orderBy: DB.itemToLearn.idxInProgram);

    List<ItemToLearn> items =
        resultItems.map((e) => RowItemToLean.fromDb(e)).map((e) => ItemToLearn(e.uri, e.uri)).toList();

    return LearningProgram(learningProgram.uri, items);
  }

  static Future<UserProgram> getUserProgram(String uri) async {
    List<Map<String, dynamic>> resultUserProgram =
        await _db.query("${DB.userProgram}", where: '${DB.userProgram.uri} = ?', whereArgs: [uri]);

    RowUserProgram userProgram = RowUserProgram.fromDb(resultUserProgram[0]);

    var learningProgram = await getLearningProgram(userProgram.uri);

    return UserProgram(userProgram.uri, learningProgram);
  }
}
