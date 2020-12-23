import 'package:flutter_test/flutter_test.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/tech_services/database/db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  void expectUserItemSentence(UserItemToLearnSentence actual, UserItemToLearnSentence matcher) {
    expect(actual.uri, matcher.uri);
    expect(actual.serverUri, matcher.serverUri);
    expect(actual.sentence, matcher.sentence);
    expect(actual.translation, matcher.translation);
    expect(actual.hint, matcher.hint);
  }

  void expectUserItemToLearn(UserItemToLearn actual, UserItemToLearn matcher) {
    expect(actual.uri, matcher.uri);
    expect(actual.serverUri, matcher.serverUri);
    expect(actual.label, matcher.label);
    expect(actual.status, matcher.status);
    expect(actual.sentences.length, matcher.sentences.length);
    for (int i = 0; i < matcher.sentences.length; i++) {
      expectUserItemSentence(actual.sentences[i], matcher.sentences[i]);
    }
  }

  void expectUserProgram(UserLearningProgram actual, UserLearningProgram matcher) {
    expect(actual.uri, matcher.uri);
    expect(actual.serverUri, matcher.serverUri);
    expect(actual.originLanguage.uri, matcher.originLanguage.uri);
    expect(actual.learnedLanguage.uri, matcher.learnedLanguage.uri);
    // TODO NICO HERE CHECK LANGUAGE LABEL WHEN IT'S IMPLEMENTED
    expect(actual.itemsToLearn.length, matcher.itemsToLearn.length);
    for (int i = 0; i < matcher.itemsToLearn.length; i++) {
      expectUserItemToLearn(actual.itemsToLearn[i], matcher.itemsToLearn[i]);
    }
  }

  test('insert then get user program', () async {
    Db db = Db();
    await db.initWith(databaseFactoryFfi, inMemoryDatabasePath);

    UserLearningProgram expected = const UserLearningProgram(
        'test_uri_user_program',
        'test_uri_server_program',
        [
          UserItemToLearn(
              'uri_item_1',
              'uri_item_1_server',
              'label_1',
              [
                UserItemToLearnSentence('item_1_sentence_1_uri', 'item_1_sentence_1_uri_serv', 'item_1_sentence_1_sen',
                    'item_1_sentence_1_tra', 'item_1_sentence_1_hint'),
                UserItemToLearnSentence('item_1_sentence_2_uri', 'item_1_sentence_2_uri_serv', 'item_1_sentence_2_sen',
                    'item_1_sentence_2_tra', 'item_1_sentence_2_hint'),
              ],
              UserItemToLearnStatus.NotLearned),
          UserItemToLearn(
              'uri_item_2',
              'uri_item_2_server',
              'label_2',
              [
                UserItemToLearnSentence('item_2_sentence_1_uri', 'item_2_sentence_1_uri_serv', 'item_2_sentence_1_sen',
                    'item_2_sentence_1_tra', 'item_2_sentence_1_hint'),
              ],
              UserItemToLearnStatus.NotLearned),
        ],
        Language('learned_language_uri', 'learned_language_label'),
        Language('origin_language_uri', 'origin_language_uri'));

    await db.insertUserLearningProgram(expected);
    UserLearningProgram result = await db.getUserLearningProgram(expected.uri);

    expectUserProgram(result, expected);
  });
}
