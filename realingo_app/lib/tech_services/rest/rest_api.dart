import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/app_config.dart';
import 'package:realingo_app/tech_services/rest/rest_data.dart';

/*
Rest API wrapper
 */
class RestApi {
  static const String _restApiBaseUrl = '${AppConfig.apiUrl}/api/v0';

  static Future<List<Language>> getAvailableOriginLanguages(String learnedLanguageUri) async {
    http.Response response =
        await http.get('$_restApiBaseUrl/available_origin_languages?learned_language_uri=$learnedLanguageUri');

    final languages = List<Language>.unmodifiable((json.decode(response.body) as List<dynamic>)
        .map((dynamic i) => RestLanguage.fromJson(i as Map<String, dynamic>))
        .map<Language>((e) => Language(e.uri, e.label)));

    return languages;
  }

  static Future<List<Language>> getAvailableLearnedLanguages() async {
    http.Response response = await http.get('$_restApiBaseUrl/available_learned_languages');

    final languages = List<Language>.unmodifiable((json.decode(response.body) as List<dynamic>)
        .map((dynamic i) => RestLanguage.fromJson(i as Map<String, dynamic>))
        .map<Language>((e) => Language(e.uri, e.label)));

    return languages;
  }

  static Future<LearningProgram> getProgram(Language learnedLanguage, Language originLanguage) async {
    http.Response response = await http.get(
        '$_restApiBaseUrl/program?learned_language_uri=${learnedLanguage.uri}&origin_language_uri=${originLanguage.uri}');
    final restProgram = RestLearningProgram.fromJson(json.decode(response.body) as Map<String, dynamic>);

    final lessons = List<LessonInProgram>.unmodifiable(
        restProgram.lessons.map<LessonInProgram>((e) => LessonInProgram(e.uri, e.label)));

    return LearningProgram(restProgram.uri, originLanguage, learnedLanguage, lessons);
  }

  static Future<Lesson> getLesson(LearningProgram program, String lessonUri) async {
    http.Response response =
        await http.get('$_restApiBaseUrl/lesson?program_uri=${program.uri}&lesson_uri=${lessonUri}');
    final restLesson = RestLesson.fromJson(json.decode(response.body) as Map<String, dynamic>);

    final sentences = List<Sentence>.unmodifiable(restLesson.sentences.map<Sentence>((e) => Sentence(
        e.uri,
        e.sentence,
        e.translation,
        e.hint,
        List<ItemInSentence>.unmodifiable(e.items.map<ItemInSentence>((e) => ItemInSentence(
            e.startIndex,
            e.endIndex,
            e.label,
            List<ItemTranslation>.unmodifiable(
                e.translations.map<ItemTranslation>((e) => ItemTranslation(e.translation, e.englishDefinition)))))))));

    return Lesson(restLesson.uri, restLesson.label, sentences);
  }

  static Future<Uint8List> getRecord(String languageUri, String sentence) async {
    http.Response response =
        await http.get('$_restApiBaseUrl/sentence_record?language_uri=$languageUri&sentence=$sentence');

    Uint8List body = response.bodyBytes;
    return body;
  }
}
