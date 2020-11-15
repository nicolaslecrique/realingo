import 'package:flutter_test/flutter_test.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/database/db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  void expectUserProgram(UserProgram actual, UserProgram matcher) {
    expect(actual.uri, matcher.uri);
    expect(actual.program.uri, matcher.program.uri);
    expect(actual.program.itemsToLearn.length, matcher.program.itemsToLearn.length);
    for (int i = 0; i < matcher.program.itemsToLearn.length; i++) {
      expect(actual.program.itemsToLearn[i].uri, matcher.program.itemsToLearn[i].uri);
      expect(actual.program.itemsToLearn[i].label, matcher.program.itemsToLearn[i].label);
    }
  }

  test('simple sqflite example', () async {
    Db db = Db();
    await db.initWith(databaseFactoryFfi, inMemoryDatabasePath);

    UserProgram expected = UserProgram(
        "test_uri_user_program",
        LearningProgram("test_uri_program", [
          ItemToLearn("uri_item_1", "label_1"),
          ItemToLearn("uri_item_2", "label_2"),
          ItemToLearn("uri_item_3", "label_3"),
        ]));

    await db.insertUserProgram(expected);
    UserProgram result = await db.getUserProgram(expected.uri);

    expectUserProgram(result, expected);
  });
}
