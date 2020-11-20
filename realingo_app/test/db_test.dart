import 'package:flutter_test/flutter_test.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/database/db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  void expectUserProgram(UserLearningProgram actual, UserLearningProgram matcher) {
    expect(actual.uri, matcher.uri);
    expect(actual.learningProgramServerUri, matcher.learningProgramServerUri);
    expect(actual.itemsToLearn.length, matcher.itemsToLearn.length);
    for (int i = 0; i < matcher.itemsToLearn.length; i++) {
      expect(actual.itemsToLearn[i].uri, matcher.itemsToLearn[i].uri);
      expect(actual.itemsToLearn[i].itemToLearn.label, matcher.itemsToLearn[i].itemToLearn.label);
      expect(actual.itemsToLearn[i].itemToLearn.uri, matcher.itemsToLearn[i].itemToLearn.uri);
      expect(actual.itemsToLearn[i].status, matcher.itemsToLearn[i].status);
    }
  }

  test('insert then get user program', () async {
    Db db = Db();
    await db.initWith(databaseFactoryFfi, inMemoryDatabasePath);

    UserLearningProgram expected = UserLearningProgram("test_uri_user_program", "test_uri_server_program", [
      UserItemToLearn(
          "uri_item_1", ItemToLearn("label_1", "test_itemToLearnServerUri_1"), UserItemToLearnStatus.NotLearned),
      UserItemToLearn(
          "uri_item_2", ItemToLearn("label_2", "test_itemToLearnServerUri_2"), UserItemToLearnStatus.KnownAtStart),
      UserItemToLearn(
          "uri_item_3", ItemToLearn("label_3", "test_itemToLearnServerUri_3"), UserItemToLearnStatus.KnownAtStart),
    ]);

    await db.insertUserLearningProgram(expected);
    UserLearningProgram result = await db.getUserLearningProgram(expected.uri);

    expectUserProgram(result, expected);
  });
}
